# GRASS GIS on HPC Henry2

This is a repository with instructions for compiling and running GRASS GIS on NCSU HPC Henry2.

## Running GRASS GIS

These are instructions for users of Henry2 on how to run GRASS GIS.
See [docs](docs) for a complete guide.

Activate and run GRASS GIS (as of May 2021, this works on Henry2 as is):

```bash
module use --append /usr/local/usrapps/gis/modulefiles
module load grass/79
grass
```

The rest of this document is about compiling GRASS GIS and making sure the above works.

## Compiling GRASS GIS

These are instructions for users of Henry2 on how to compile (new or custom version of)
GRASS GIS. This assumes you are using Bash.

Set a "prefix" variable for conda environment to be used throughout the workflow:

```bash
CONDA_PREFIX=/usr/local/usrapps/.../grass-deps-conda-env
```

Set another "prefix" variable for a directory where GRASS GIS will be installed:

```bash
INSTALL_PREFIX=/usr/local/usrapps/.../grass-install
```

Potentially, these two variables can be the the same, i.e., you can install GRASS GIS
into the conda environment.

Get recent GCC version:

```bash
module load gcc
```

Activate conda:

```bash
module load conda
```

Get and compile dependencies using conda:

```bash
conda env create --file environment.yml --prefix $CONDA_PREFIX
```

To make GRASS GIS compile and run, set:

```bash
export LD_LIBRARY_PATH=$CONDA_PREFIX/lib:$LD_LIBRARY_PATH
```

Get and compile GRASS GIS:

```bash
bash ./compile.sh master $CONDA_PREFIX $INSTALL_PREFIX
```

Test:

```bash
bash ./test-quick.sh
bash ./test-thorough.sh
```

Test interactively, possibly with GUI (assuming you can run GUI applications):

```bash
grass79
```

## Run

Set the environmental variables:

```tcsh
set PREFIX=/usr/local/usrapps/.../bin/
setenv LD_LIBRARY_PATH $LD_LIBRARY_PATH\:$PREFIX/lib\:$PREFIX/lib64
setenv PATH $PATH\:$PREFIX/bin
```

Activate conda and the conda environment:

```tcsh
module load conda
conda activate /usr/local/usrapps/.../conda-for-wx
```

Run:

```tcsh
grass79 ...
```

## Setup for use

Create a file to be sourced (place it into `$PREFIX`):

```tcsh
# This file must be used with "source bin/activate" from tcsh.
# It is not useful for anything to run it directly.
set PREFIX=/usr/local/usrapps/.../bin/
setenv LD_LIBRARY_PATH $LD_LIBRARY_PATH\:$PREFIX/lib\:$PREFIX/lib64
setenv PATH $PATH\:$PREFIX/bin
module load conda
conda activate $PREFIX/../conda-for-wx
```

Create a symlink to the executable to make the command version-independent:

```tcsh
ln -s ${PREFIX}bin/grass79 ${PREFIX}bin/grass
```
