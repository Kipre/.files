const std = @import("std");
const builtin = @import("builtin");
const assert = std.debug.assert;
const io = std.io;
const fs = std.fs;
const mem = std.mem;
const eql = mem.eql;
const process = std.process;
const testing = std.testing;
const expect = std.testing.expect;
const Allocator = mem.Allocator;
const cleanExit = std.process.cleanExit;
const native_os = builtin.os.tag;

const LinkConfig = struct {
    name: []const u8,
    windows: ?[]const u8 = null,
    linux: ?[]const u8 = null,
};

const Config = struct {
    links: []const LinkConfig,
};

pub fn fatal(comptime format: []const u8, args: anytype) noreturn {
    std.log.err(format, args);
    process.exit(1);
}

const usage =
    \\Usage: gardien [command] [options]
    \\
    \\Commands:
    \\
    \\  setup            Create symlinks to place config files in the system
    \\
    \\General Options:
    \\
    \\  -h, --help       Print command-specific usage
    \\
;

pub fn main() anyerror!void {
    // crash_report.initialize();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    var arena_instance = std.heap.ArenaAllocator.init(gpa.allocator());
    defer arena_instance.deinit();

    const arena = arena_instance.allocator();
    const args = try process.argsAlloc(arena);
    return mainArgs(arena, args);
}

fn mainArgs(alloc: Allocator, args: []const []const u8) !void {
    const out_file = std.io.getStdOut();
    if (args.len <= 1) {
        try out_file.writer().print("{s}", .{usage});
        fatal("expected command argument", .{});
    }

    const cmd = args[1];
    const cmd_args = args[2..];
    if (mem.eql(u8, cmd, "setup")) {
        return cmdSetup(alloc, cmd_args);
    } else {
        try out_file.writer().print("{s}", .{usage});
        fatal("unknown command: {s}", .{cmd});
    }
}

const usage_setup =
    \\Usage: zig setup [options]
    \\
    \\   Stupid script for creating creating symlinks for dotfiles
    \\
    \\Options:
    \\  --dry-run                     Don't do anything, just run checks and print results
    \\  --force                       Overwrite existing links
    \\  -h, --help                    Print this help and exit
    \\
;

fn readConfig(alloc: Allocator) !std.json.Parsed(Config) {
    const data = try std.fs.cwd().readFileAlloc(alloc, "links.json", 1024);
    defer alloc.free(data);
    const parsed = try std.json.parseFromSlice(Config, alloc, data, .{
        .allocate = .alloc_always,
        .ignore_unknown_fields = true,
    });
    return parsed;
}

var symlink_buffer: [fs.MAX_PATH_BYTES]u8 = undefined;

fn handleSingleLink(alloc: Allocator, home_dir: []const u8, source_dir: []const u8, link: LinkConfig, dry_run: bool) !void {
    const location_field = comptime if (native_os == .windows) "windows" else "linux";

    const maybe_location = @field(link, location_field);
    if (maybe_location == null) return;

    const location = maybe_location.?;

    const out_file = std.io.getStdOut();
    const cwd = std.fs.cwd();

    const destination = try fs.path.resolve(alloc, &[_][]const u8{ home_dir, location, link.name });
    defer alloc.free(destination);
    const relative_source = try fs.path.resolve(alloc, &[_][]const u8{ source_dir, link.name });
    defer alloc.free(relative_source);

    const source = try cwd.realpathAlloc(alloc, relative_source);
    defer alloc.free(source);

    const source_is_a_dir = if (cwd.openDir(source, .{})) |_| true else |err| if (err == error.NotDir) false else return err;

    const observed_link = cwd.readLink(destination, &symlink_buffer) catch |err| {
        if (err == error.FileNotFound) {
            if (dry_run) {
                try out_file.writer().print("Symlink for {s} does not exist\n", .{link.name});
            } else {
                const destination_directory = fs.path.dirname(destination);
                if (destination_directory == null) return error.FileNotFound;

                try cwd.makePath(destination_directory.?);

                try cwd.symLink(source, destination, .{ .is_directory = source_is_a_dir });
                try out_file.writer().print("Symlink created for {s}\n", .{link.name});
            }
            return;
        } else if (err == error.Unexpected or err == error.NotLink) {
            try out_file.writer().print("Found some issue while reading {s}\n", .{destination});
        }
        return err;
    };

    if (mem.eql(u8, source, observed_link)) {
        try out_file.writer().print("Symlink for {s} is already good\n", .{link.name});
    }
}

fn cmdSetup(alloc: Allocator, args: []const []const u8) !void {
    var dry_run = false;
    // var force = false;
    {
        var i: usize = 0;
        while (i < args.len) : (i += 1) {
            const arg = args[i];
            if (mem.startsWith(u8, arg, "-")) {
                if (mem.eql(u8, arg, "-h") or mem.eql(u8, arg, "--help")) {
                    try io.getStdOut().writeAll(usage_setup);
                    return cleanExit();
                } else if (mem.eql(u8, arg, "--dry-run")) {
                    dry_run = true;
                    continue;
                } else {
                    fatal("unrecognized parameter: '{s}'", .{arg});
                }
            } else {
                fatal("unexpected extra parameter: '{s}'", .{arg});
            }
        }
    }

    const home_dir_env_var_name = if (native_os == .windows) "userprofile" else "HOME";
    const home_dir: []const u8 = std.process.getEnvVarOwned(alloc, home_dir_env_var_name) catch {
        fatal("Could not find the home directory", .{});
    };

    const parsed = try readConfig(alloc);
    defer parsed.deinit();
    const config = parsed.value;

    for (config.links) |link| {
        handleSingleLink(alloc, home_dir, "", link, dry_run) catch |err| {
            if (err == error.FileNotFound) {
                fatal("Some file was not found", .{});
            }
            if (err == error.Unexpected) {
                fatal("Please make sure the destinations are ok", .{});
            }
        };
    }
}

test "does what needs to be done" {
    var tmp_dir = std.testing.tmpDir(.{ .iterate = true });
    defer tmp_dir.cleanup();
    try tmp_dir.dir.writeFile("source.txt", "hello");
    const alloc = std.testing.allocator;
    const path = try tmp_dir.dir.realpathAlloc(alloc, ".");

    defer alloc.free(path);

    handleSingleLink(alloc, path, path, .{ .name = "config" }, true) catch |err| {
        try expect(err == error.FileNotFound);
    };

    {
        var iter = tmp_dir.dir.iterate();
        try testing.expectEqualStrings("source.txt", if (try iter.next()) |v| v.name else "");
        try expect((try iter.next()) == null);
    }

    try handleSingleLink(alloc, path, path, .{ .name = "source.txt", .windows = "ok", .linux = "ok" }, true);
    {
        var iter = tmp_dir.dir.iterate();
        try testing.expectEqualStrings("source.txt", if (try iter.next()) |v| v.name else "");
        try expect((try iter.next()) == null);
    }

    try handleSingleLink(alloc, path, path, .{ .name = "source.txt", .windows = "ok", .linux = "ok" }, false);
    {
        var iter = tmp_dir.dir.iterate();
        try testing.expectEqualStrings("ok", if (try iter.next()) |v| v.name else "");
        try testing.expectEqualStrings("source.txt", if (try iter.next()) |v| v.name else "");
        try expect((try iter.next()) == null);
    }
    var buffer: [fs.MAX_PATH_BYTES]u8 = undefined;

    const written_symlink = try tmp_dir.dir.readLink("ok/source.txt", &buffer);
    const actual_path = try tmp_dir.dir.realpathAlloc(alloc, "source.txt");
    defer alloc.free(actual_path);
    try testing.expectEqualStrings(actual_path, written_symlink);
}

test "file already exists" {
    var tmp_dir = std.testing.tmpDir(.{ .iterate = true });
    defer tmp_dir.cleanup();

    try tmp_dir.dir.writeFile("source.txt", "hello");
    try tmp_dir.dir.writeFile("destination.txt", "heyy");

    const alloc = std.testing.allocator;
    const path = try tmp_dir.dir.realpathAlloc(alloc, ".");
    defer alloc.free(path);

    if (handleSingleLink(alloc, path, path, .{ .name = "source.txt", .windows = "", .linux = "" }, true)) |_| {
        // this was supposed to crash
        try expect(false);
    } else |err| {
        try expect(err == error.Unexpected or err == error.NotLink);
    }

    {
        var iter = tmp_dir.dir.iterate();
        try testing.expectEqualStrings("destination.txt", if (try iter.next()) |v| v.name else "");
        try testing.expectEqualStrings("source.txt", if (try iter.next()) |v| v.name else "");
        try expect((try iter.next()) == null);
    }

    const content = try tmp_dir.dir.readFileAlloc(alloc, "destination.txt", 100);
    defer alloc.free(content);
    try testing.expectEqualStrings("heyy", content);
}

test "symlink already exists" {
    var tmp_dir = std.testing.tmpDir(.{ .iterate = true });
    defer tmp_dir.cleanup();

    try tmp_dir.dir.writeFile("source.txt", "hello");
    const alloc = std.testing.allocator;
    const path = try tmp_dir.dir.realpathAlloc(alloc, ".");
    defer alloc.free(path);

    try handleSingleLink(alloc, path, path, .{ .name = "source.txt", .windows = "ok", .linux = "ok" }, false);
    try handleSingleLink(alloc, path, path, .{ .name = "source.txt", .windows = "ok", .linux = "ok" }, false);
    {
        var iter = tmp_dir.dir.iterate();
        try testing.expectEqualStrings("ok", if (try iter.next()) |v| v.name else "");
        try testing.expectEqualStrings("source.txt", if (try iter.next()) |v| v.name else "");
        try expect((try iter.next()) == null);
    }
}

test "deep destination" {
    var tmp_dir = std.testing.tmpDir(.{ .iterate = true });
    defer tmp_dir.cleanup();

    try tmp_dir.dir.writeFile("source.txt", "hello");
    const alloc = std.testing.allocator;
    const path = try tmp_dir.dir.realpathAlloc(alloc, ".");
    defer alloc.free(path);

    try handleSingleLink(alloc, path, path, .{ .name = "source.txt", .windows = "ok/this/path", .linux = "ok/this/path" }, true);
    {
        var iter = tmp_dir.dir.iterate();
        try testing.expectEqualStrings("source.txt", if (try iter.next()) |v| v.name else "");
        try expect((try iter.next()) == null);
    }

    try handleSingleLink(alloc, path, path, .{ .name = "source.txt", .windows = "ok/this/path", .linux = "ok/this/path" }, false);
    {
        var iter = tmp_dir.dir.iterate();
        try testing.expectEqualStrings("ok", if (try iter.next()) |v| v.name else "");
        try testing.expectEqualStrings("source.txt", if (try iter.next()) |v| v.name else "");
        try expect((try iter.next()) == null);
    }

    var buffer: [fs.MAX_PATH_BYTES]u8 = undefined;

    const written_symlink = try tmp_dir.dir.readLink("ok/this/path/source.txt", &buffer);
    const actual_path = try tmp_dir.dir.realpathAlloc(alloc, "source.txt");
    defer alloc.free(actual_path);
    try testing.expectEqualStrings(actual_path, written_symlink);
}
