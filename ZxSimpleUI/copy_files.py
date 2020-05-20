import os
# Ref: https://stackoverflow.com/a/600612
import pathlib
import shutil
import sys
import json

config_file = "copy_files_config.json"
addon_name = "ZxSimpleUI"

ignored_paths = [config_file, ".gitignore"]
ignored_paths = set(ignored_paths)

class CopyAddonFiles:
    def __init__(self):
        self.src = ""
        self.dest = ""

    def set_src_and_dest(self):
        with open(config_file, "r") as file:
            data = json.load(file)
        self.src = data["src"]
        self.dest = data["dest"]
        self.dest = os.path.join(self.dest, addon_name)

    def execute(self):
        for root, dirs, files in os.walk(self.src):
            for filename in files:
                if filename not in ignored_paths:
                    src_full_path = os.path.join(root, filename)
                    dest_full_path = os.path.join(self.dest, src_full_path)
                    print("{0} --> {1}".format(
                        src_full_path.replace("\\", "/"), dest_full_path.replace("\\", "/")))
                    head, tail = os.path.split(dest_full_path)
                    pathlib.Path(head).mkdir(parents=True, exist_ok=True)
                    shutil.copy(src_full_path, dest_full_path)

if __name__ == "__main__":
    copy_addon_file = CopyAddonFiles()
    copy_addon_file.set_src_and_dest()
    if not os.path.isfile(config_file):
        print("Configuration file does not exist! File name: {}".format(config_file))
        exit(1)
    if len(sys.argv) > 1:
        arg1 = sys.argv[1]
        if arg1 == "--remove-dest":
            if os.path.isdir(copy_addon_file.dest):
                print("Removing {0}".format(copy_addon_file.dest.replace("\\", "/")))
                shutil.rmtree(copy_addon_file.dest)

    copy_addon_file.execute()
