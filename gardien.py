import argparse
import os
import tomllib
import shutil
import urllib.request
import zipfile
import contextlib
import shutil

dir_path = os.path.dirname(os.path.realpath(__file__))
exe_path = dir_path + "/executables"


def open_config(file):
    with open(f"{dir_path}/{file}", "rb") as f:
        config = tomllib.load(f)
    return config


def overwrite_symlink(source, destination):
    with contextlib.suppress(OSError):
        os.unlink(destination)
    with contextlib.suppress(OSError):
        shutil.rmtree(destination)
    os.symlink(source, destination)


def create_symlinks(dry_run=False, force=False, **kwargs):
    config = open_config("links.toml")

    # other platforms are not supported
    platform = "windows" if os.name == "nt" else "linux"
    print(f"Running on {platform}")

    home = os.getenv("HOME")
    print("HOME", home)

    for item in config["links"]:
        if platform not in item:
            continue

        destination = f"{item[platform]}/{item['name']}".replace("~", home)
        source = f"{dir_path}/{item['name']}"

        is_not_empty = os.path.exists(destination)
        is_already_linked = os.path.islink(destination)

        if is_already_linked:
            print(f"{destination} is already a symlink")
            existing_link = os.readlink(destination)
            if os.path.samefile(existing_link, destination):
                overwrite_symlink(source, destination)
                print(f"{destination} already points to {source}")
            elif not dry_run:
                print(
                    f"{destination} was pointing to {existing_link}, updated link to {destination}")
            else:
                print(
                    f"{destination} is pointing to {existing_link}, will need to be updated link to {destination}")

        elif is_not_empty:
            if force:
                overwrite_symlink(source, destination)
                print(f"{destination} was not empty but wrote the symlink anyways")
            elif not dry_run:
                print(
                    f"Warning: {destination} is not empty, pass --force to overwrite it")
            else:
                print(
                    f"{destination} has some file, make sure to check before ovewriting them")

            continue

        else:
            if dry_run:
                print(f"{destination} seems to be free")
            else:
                destination_folder = os.path.dirname(destination)
                if not os.path.exists(destination_folder):
                    os.makedirs(destination_folder)
                os.symlink(source, destination)
                print(f"{destination} wrote symlink in empty place")


def download_modules(**kargs):
    config = open_config("executables.toml")

    if os.path.exists(exe_path):
        shutil.rmtree(exe_path)

    for item in config['exe']:
        filename, _ = urllib.request.urlretrieve(item["source"])

        if filename.endswith('.zip') or item["source"].endswith(".zip"):
            with zipfile.ZipFile(filename, "r") as f:
                f.extract(item["name"], path=exe_path)
        else:
            raise NotImplementedError()


parser = argparse.ArgumentParser(
    prog='gardien',
    description='Stupid script for creating creating symlinks for dotfiles',
    epilog='Here you go')


subparsers = parser.add_subparsers(help='commands', required=True)

pack_parser = subparsers.add_parser('pack', help='package utilities')
pack_parser.set_defaults(func=download_modules)

conf_parser = subparsers.add_parser('conf', help='config utilities')
conf_parser.set_defaults(func=create_symlinks)

conf_parser.add_argument('--dry-run', dest='dry_run', action='store_true',
                         help='do not do anything, just run checks')

conf_parser.add_argument('--force', dest='force', action='store_true',
                         help='overwrite existing links')


if __name__ == "__main__":
    args = parser.parse_args()
    args.func(**vars(args))
