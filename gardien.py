import argparse
import os
import tomllib

dir_path = os.path.dirname(os.path.realpath(__file__))


def create_symlinks(dry_run=False, force=False):
    with open(dir_path + "/links.toml", "rb") as f:
        config = tomllib.load(f)
    
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

        if dry_run:
            if is_already_linked:
                print(f"{destination} is already a symlink")

            elif is_not_empty:
                print(f"Warning: {destination} is not empty")

            continue

        if force and is_already_linked:
            print("Removing existing link")
            os.unlink(destination)

        try:
            os.symlink(source, destination)
            print(f"Linking {item['name']} with {destination}")
        except FileExistsError as e:
            raise e
            print(f"Skipping {destination} because it already exists: {str(e)}")


parser = argparse.ArgumentParser(
                    prog='gardien',
                    description='Stupid script for creating creating symlinks for dotfiles',
                    epilog='Here you go')

parser.add_argument('--dry-run', dest='dry_run', action='store_true',
                    help='do not do anything, just run checks')

parser.add_argument('--force', dest='force', action='store_true',
                    help='overwrite existing links')

if __name__ == "__main__":
    args = parser.parse_args()
    create_symlinks(**vars(args))
