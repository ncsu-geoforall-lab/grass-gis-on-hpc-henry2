#!/usr/bin/env python

import sys
import os
from pathlib import Path
import re

def read_and_record_shortcuts(path, filename):
    path = Path(path)
    symlinks = sorted([x for x in path.iterdir() if x.is_symlink()])

    default_version = None
    version_file = path / ".version"
    if version_file.exists():
        version_content = version_file.read_text()
        match = re.search("^set ModulesVersion (.+)$", version_content, flags=re.MULTILINE)
        if match:
            default_version = match.group(1)
        else:
            exit("Module .version file exists, but ModulesVersion seems to be missing")
        if not (path / default_version).exists():
            exit(f"Module .version file exists, but version '{default_version}' does not")

    with open(filename, "w") as record:
        if default_version:
            record.write(f"default: {default_version}\n")
        if symlinks:
            record.write(f"symbolic_links:\n")
            for symlink in symlinks:
                target = os.readlink(symlink)
                if not symlink.exists():
                    exit(f"Symlink '{symlink}' exists, but the target '{target}' does not")
                record.write(f"  - name: {symlink.name}\n")
                record.write(f"    points_to: {target}\n")


def main():
    if len(sys.argv) != 2:
        exit(f"Usage: {sys.argv[0]} MODULE_DIR")
    read_and_record_shortcuts(sys.argv[1], "shortcuts/shortcuts.yml")

if __name__ == "__main__":
    main()
