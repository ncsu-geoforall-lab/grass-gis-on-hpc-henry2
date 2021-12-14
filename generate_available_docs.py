#!/usr/bin/env python

"""Generate documentation from available directory

The Markdown generating functions assumes that prettier will be executed
afterwards to make stylistic changes.
"""

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
            f"{meta['cloned_version']} | "
            f"`{meta['commit']}` |\n"
        )


def write_installed_versions(paths, file):
    """Create documentation for all installed versions"""
    file.write(
        "## Installed versions\n\n"
        "These are all the currently installed (available) versions. "
        "(New versions are installed and added here as needed.)\n\n"
    )
    file.write("| Version | module load | Based On | Commit Hash (ID) |\n")
    file.write("| --- | --- | --- | --- |\n")
    for version in paths:
        write_version_info(version, file)


def software_versions_to_doc(paths, filename):
    """Generate documentation for installed software"""
    with open(filename, "w") as file:
        file.write("# Available software\n\n")
        for version in reversed(paths):
            meta_file = version / "metadata.yml"
            if meta_file.exists():
                meta = yaml.safe_load(meta_file.read_text())
                file.write(f"## Module {meta['module_load']}\n\n")
                file.write("Activate module using:\n")
                file.write("\n```sh\n")
                file.write(f"{meta['module_example']}")
                file.write("```\n\n")
            else:
                default_module_name = "grass"
                file.write(f"## Module {default_module_name}/{version.name}\n")
            software_file = version / "software.yml"
            if software_file.exists():
                file.write("| Software | Version | Description | Interfaces |\n")
                file.write("| --- | --- | --- | --- |\n")
                softwares = yaml.safe_load(software_file.read_text())
                for software in softwares["software"]:
                    software_version = software["version"]
                    if not software_version:
                        continue
                    software_description = software["description"]
                    if not software_description:
                        software_description = ""
                    software_interfaces = software["interfaces"]
                    if not software_interfaces:
                        software_interfaces = ""
                    file.write(
                        f"| {software['name']} |"
                        f" {software_version} |"
                        f" {software_description} |"
                        f" {software_interfaces} |\n"
                    )
                file.write("\n")


def meta_to_doc(path, filename):
    """Read metadata from a directory and write documentation to a Markdown file"""
    path = Path(path)
    shortcuts_file = path / "shortcuts.yml"
    filename = Path(filename)

    with open(filename, "w") as file:
        file.write(
            "# Available versions\n\n"
            "There are GRASS GIS versions current available on Henry2.\n\n"
        )
        if shortcuts_file.exists():
            shortcuts = yaml.safe_load(shortcuts_file.read_text())
            write_shortcuts(shortcuts, file)
        dirs = sorted([x for x in path.iterdir() if x.is_dir()])
        write_installed_versions(dirs, file)
        software_versions_to_doc(dirs, "docs/software.md")
        file.write("\n")
        file.write("## See also\n\n")
        file.write(
            "- [Activating](activating.md) "
            "for information on activating specific versions\n"
        )
        file.write(
            "- [available](../available) "
            "directory for all information about installed versions\n"
        )


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
