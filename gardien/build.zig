const std = @import("std");

const targets: []const std.Target.Query = &.{
    // .{ .cpu_arch = .aarch64, .os_tag = .macos },
    // .{ .cpu_arch = .aarch64, .os_tag = .linux },
    .{ .cpu_arch = .x86_64, .os_tag = .linux, .abi = .gnu },
    // .{ .cpu_arch = .x86_64, .os_tag = .linux, .abi = .musl },
    .{ .cpu_arch = .x86_64, .os_tag = .windows },
};

pub fn build(b: *std.Build) !void {
    for (targets) |t| {
        const name = if (t.os_tag == .windows) "gardien" else "gardien-exe";
        const exe = b.addExecutable(.{
            .name = name,
            .root_source_file = .{ .path = "src/main.zig" },
            .target = b.resolveTargetQuery(t),
            .optimize = .ReleaseSmall,
        });

        const target_output = b.addInstallArtifact(exe, .{
            .dest_dir = .{
                .override = .{
                    .custom = "../..",
                },
            },
        });

        b.getInstallStep().dependOn(&target_output.step);
    }
}
