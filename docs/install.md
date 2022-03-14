# Compiling and installing GRASS GIS

These are instructions for users of Henry2 on how to compile (new or custom version of)
GRASS GIS. If you just want to use GRASS GIS, activating an HPC module will be enough.
This document is about making sure the HPC modules work.

This guide assumes you are using Bash, but with some modifications, it will work
in tcsh as well. It further assumes, you are in the _touch_ group on Henry2.
To have appropriate space for the installation, you should ask for a _usrapps_
directory for the group (project) you are part of. Here, we will use
a directory `/usr/local/usrapps/geospatial` as an example.
Finally, it assumes you already set up conda so that it caches packages somewhere else
than your home otherwise you will run out of space.

## Compile and install

Create a directory for the installation and enter that directory:

```sh
cd /usr/local/usrapps/geospatial
```

Start by cloning this repository (if not cloned already):

```sh
git clone https://github.com/ncsu-geoforall-lab/grass-gis-on-hpc-henry2.git
```

Then enter the directory created by the above command:

```sh
cd grass-gis-on-hpc-henry2
```

If you are not using a fresh clone, ensure you are using the latest _main_ branch:

```sh
git checkout main
git fetch origin
git rebase origin/main
```

Pick a install directory and GRASS GIS version your want to use.
For the version, you need:

- version number used for the directories, e.g., the full version number,
  e.g., 7.8.5, or, for development versions, two-number version number and
  a current date, or first seven characters from the commit hash
- version number as it may appear in the main executable name,
  i.e., first two version numbers without a dot (used only before 8.0,
  ignored in the install script for 8.0 and above)
- identifier of the version in Git, i.e., a tag, branch name, or commit hash.

When ready, run the `install_grass.sh` script:

```sh
./install_grass.sh /usr/local/usrapps/geospatial/ 8.1 81 fdff46c1a39ff41a6f805bee0dc74fb2bf246eb5
```

The process will take roughly 30 minutes and it is using only one core.

## Updating all versions

The following versions are currently being updated when appropriate.
The builds for branches can be used as is. For the builds of tags,
replace `x` with the current minor version.

```sh
time ./install_grass.sh /usr/local/usrapps/geospatial 8.1-$(date -I) 81 main
time ./install_grass.sh /usr/local/usrapps/geospatial 8.0-$(date -I) 80 releasebranch_8_0
time ./install_grass.sh /usr/local/usrapps/geospatial 8.0.1 80 8.0.1
time ./install_grass.sh /usr/local/usrapps/geospatial 7.8.x 78 7.8.x
```

The _time_ command is used just to get some more information about the build.

## Test

To test the installation, you need to load the created module first:

```sh
module use --append /usr/local/usrapps/geospatial/modulefiles
```

```sh
module avail
```

```sh
module load grass/8.1
```

Then run the test scripts with the executable name and source code directory
as parameters:

```bash
grass --version
./test_quick.sh grass
./test_thorough.sh grass grass-code-8.1 .
```

The `grass-code-` part is hardcoded in the `compile.sh` script the second part is
the full version number or whatever was used in place of it for development versions.
The `.` at the end is the directory where to download test
data and run the tests. In this case, it is the current directory.

Note that the tests may use multiple (or even all available cores).

Test interactively, possibly with GUI (assuming you can run GUI applications):

```bash
grass
```

## Modify the default module

If you already have other installations available as modules, you
may want to modify the default version for the _grass_ module.
Besides the desired version, you need the directory with module files
which is `modulefiles/grass` under your installation directory.
Here, we would run:

```sh
./set_default_module_version.sh /usr/local/usrapps/geospatial/modulefiles/grass 8.0.1
```

## Whole workflow

Build and test:

```sh
time ./install_grass.sh /usr/local/usrapps/geospatial 8.0.1 80 8.0.1
module use --append /usr/local/usrapps/geospatial/modulefiles
module load grass/8.0.1
grass --version
./test_quick.sh grass
time ./test_thorough.sh grass grass-code-8.0.1/ .
```

Record versions of all relevant software packages installed
(requires the module to be loaded):

```sh
./record_software_versions.sh 8.0.1
```

Optionally, set the version as the default module version:

```sh
./set_default_module_version.sh /usr/local/usrapps/geospatial/modulefiles/grass 8.0.1
```

For each minor version, create symbolic link to the latest installed version in that
minor version series:

```bash
(cd ../modulefiles/grass/ && ln -sf 8.0.1 8.0 && ls -la)
```

Record the current defaults and symbolic links as shortcuts
(collects information for all installed version):

```sh
./record_shortcuts.py ../modulefiles/grass/
```

Add the available directory to Git, to record the new subdirectories
and updated shortcuts:

```sh
git add available/
git checkout -b add-8.0.1
git commit -m "Add version 8.0.1"
git push --set-upstream origin add-8.0.1
```

Additionally, on a local machine, generate documentation:

```sh
./generate_available_docs.py
npx prettier --write .
```

## Compiling modified GRASS GIS source code

See the necessary and some optional steps in the `install_grass.sh`
and `compile.sh` scripts which serve as completely functional examples.
Basically, you need to:

- Load required modules.
- Create conda environment and activate it (see `install_grass.sh`).
- Compile the source code (see `compile.sh`).
- Optionally, create a module file.

Note that GRASS GIS uses the program _touch_ during compilation which means
that you need to be in the _touch_ group on Henry2 or you need to remove
usage of _touch_ from the `man/Makefile` file.
