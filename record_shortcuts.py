#!/usr/bin/env python

"""Record default module version and symlinks as shortcuts"""

import os
import re
import sys
from datetime import datetime
from pathlib import Path


def read_and_record_shortcuts(path, filename):
    """Read content of the directory, check validity, record to YAML file"""
    path = Path(path)
    symlinks = sorted([x for x in path.iterdir() if x.is_symlink()])

    default_version = None
    version_file = path / ".version"
    if version_file.exists():
        version_content = version_file.read_text()
        match = re.search(
            "^set ModulesVersion (.+)$", version_content, flags=re.MULTILINE
        )
        if match:
            default_version = match.group(1)
        else:
            sys.exit(
                "Module .version file exists, but ModulesVersion seems to be missing"
            )
        if not (path / default_version).exists():
            sys.exit(
                f"Module .version file exists, but version '{default_version}' does not"
            )

    with open(filename, "w") as record:
        date = datetime.today().strftime("%Y-%m-%d")
        record.write(f"date: {date}\n")
        if default_version:
            record.write(f"default: {default_version}\n")
        if symlinks:
            record.write("symbolic_links:\n")
            for symlink in symlinks:
                target = os.readlink(symlink)
                if not symlink.exists():
                    sys.exit(
                        f"Symlink '{symlink}' exists,"
                        f" but the target '{target}' does not"
                    )
                record.write(f"  - name: {symlink.name}\n")
                record.write(f"    points_to: {target}\n")


def main():
    """Check parameters, make sure output directory exists, record shortcuts"""
    if len(sys.argv) != 2:
        sys.exit(f"Usage: {sys.argv[0]} MODULE_DIR")
    metadata_dir = Path("available")
    metadata_dir.mkdir(exist_ok=True)
    read_and_record_shortcuts(sys.argv[1], metadata_dir / "shortcuts.yml")


if __name__ == "__main__":
    main()
