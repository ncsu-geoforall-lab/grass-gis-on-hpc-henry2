# Compiling and installing GRASS GIS

These are instructions for users of Henry2 on how to compile (new or custom version of)
GRASS GIS. If you just want to use GRASS GIS, activating an HPC module will be enough.
This document is about making sure the HPC modules work.

This guide assumes you are using Bash, but with some modifications, it will work
in tcsh as well. It further assumes, you are in the _touch_ group on Henry2.
To have appropriate space for the installation, you should ask for a _usrapps_
directory for the group (project) you are part of. Here, we will use
a directory `/usr/local/usrapps/mitasova` as an example.
Finally, it assumes you already set up conda so that it caches packages somewhere else
than your home otherwise you will run out of space.

## Compile and install

Create a directory for the installation and enter that directory:

```sh
mkdir /share/usrapps/mitasova/grass/
cd /share/usrapps/mitasova/grass/
```

Start by cloning this repository:

```sh
git clone https://github.com/ncsu-geoforall-lab/grass-gis-on-hpc-henry2.git
```

Then enter the directory created by the above command:

```sh
cd grass-gis-on-hpc-henry2
```

Use a text editor to modify these two lines in the `install_grass.sh` script:

```sh
GRASS_INSTALL_REPO=/usr/local/usrapps/mitasova/grass-gis-on-hpc-henry2/
BASE_DIR=/usr/local/usrapps/mitasova/grass/
```

Then run the script:

```sh
./install_grass.sh 7.9 79 e5379bbd7e534071eae392bf416865fdbf109f01
```

The process will take roughly 30 minutes and it is using only one core.

## Test

To test the installation, you need to load the created module first:

```sh
module use --append /usr/local/usrapps/mitasova/grass/modulefiles
```

```sh
module avail
```

```sh
module load grass/7.9
```

Then run the test scripts with the executable and directory
with source code as parameters:

```bash
grass --version
./test-quick.sh grass
./test-thorough.sh grass grass-code-e5379bbd7e534071eae392bf416865fdbf109f01
```

(The `grass-code-` part is hardcoded in the `compile.sh` script.)

Note that the tests may use multiple (or even all available cores).

Test interactively, possibly with GUI (assuming you can run GUI applications):

```bash
grass
```

## Modify the default module

If you already have other installations available as modules, you
may want to modify the default module. Edit a `.version` file
which is in the `modulefiles/grass` subdirectory,
e.g., `/usr/local/usrapps/mitasova/grass/modulefiles/grass/.version`.

The contents determines what is the default version for the module _grass_:

```text
#%Module

set ModulesVersion 7.9
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