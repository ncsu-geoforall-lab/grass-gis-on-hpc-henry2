#!/usr/bin/env python

"""Generate documentation from available directory"""

import sys
from pathlib import Path

import yaml


def write_symlinks(shortcuts, file):
    """Create documentation for symbolic links"""
    for symlink in shortcuts["symbolic_links"]:
        name = symlink["name"]
        points_to = symlink["points_to"]
        file.write(f"| grass/{name} | `module load grass/{name}` | {points_to} |\n")


def write_shortcuts(shortcuts, file):
    """Create documentation for default version and symbolic links"""
    file.write(
        "## Shortcuts\n\n"
        f"These are the available shortcuts as of {shortcuts['date']}. "
        "Each shortcut points to a specific installed version.\n"
        "The shortcuts are provided for convenience in addition "
        "to the installed versions.\n"
        "(Some shortcuts change as new versions are introduced.)\n\n"
    )
    file.write("| Shortcut | module load | Translates to |\n")
    file.write("| --- | --- | --- |\n")
    file.write(f"| grass | `module load grass` | {shortcuts['default']} |\n")
    write_symlinks(shortcuts, file)
    file.write("\n")


def write_version_info(version, file):
    """Create documentation for installed version"""
    meta_file = version / "metadata.yml"
    if meta_file.exists():
        meta = yaml.safe_load(meta_file.read_text())
        file.write(
            f"| {meta['module_version']} | "
            f"`module load {meta['module_load']}` | "
            f"{meta['cloned_version']} |\n"
        )


def meta_to_doc(path, filename):
    """Read metadata from a directory and write documentation to a Markdown file"""
    path = Path(path)
    shortcuts_file = path / "shortcuts.yml"
    filename = Path(filename)

    with open(filename, "w") as file:
        file.write(
            "# Available Versions\n\n"
            "There are GRASS GIS versions current available on Henry2.\n\n"
        )
        if shortcuts_file.exists():
            shortcuts = yaml.safe_load(shortcuts_file.read_text())
            write_shortcuts(shortcuts, file)
        dirs = sorted([x for x in path.iterdir() if x.is_dir()])

        file.write(
            "## Installed Versions\n\n"
            "These are all the currently installed (available) versions. "
            "(New versions are installed and added here as needed.)\n\n"
        )
        file.write("| Version | module load | Based On |\n")
        file.write("| --- | --- | --- |\n")
        for version in dirs:
            write_version_info(version, file)


def main():
    """Process command line parameters and run the conversion"""
    if len(sys.argv) == 1:
        metadata_dir = Path("available")
        doc_file = Path("docs/available.md")
    elif len(sys.argv) == 3:
        metadata_dir = Path(sys.argv[1])
        doc_file = Path(sys.argv[2])
    else:
        sys.exit(f"Usage: {sys.argv[0]} [DIR FILE]")
    meta_to_doc(metadata_dir, doc_file)


if __name__ == "__main__":
    main()
