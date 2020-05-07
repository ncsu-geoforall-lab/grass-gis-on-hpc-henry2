# GRASS GIS on HPC Henry2

This is a repository with instructions for compiling and running GRASS GIS on NCSU HPC Henry2.

## Running GRASS GIS

These are instructions for users of Henry2 on how to run GRASS GIS.

Activate GRASS GIS in *tcsh* shell (as of May 2020, this will run on Henry2 as is):

```
source /usr/local/usrapps/mitasova/bin/activate-grass.tcsh
```

Run GRASS GIS:

```
grass
```

The rest of this document is about compiling GRASS GIS and making sure the above works.

## Compile

Set the the prefix variable to be used throughout the workflow:

```
set PREFIX=/usr/local/usrapps/.../bin/
```

```
mkdir $PREFIX
```

Some dependencies use cmake, so load it:

```
module load cmake
```

Get and compile dependencies:

```
tcsh -e ./dependencies.sh $PREFIX
```

To make GRASS GIS compile and run, set:

```
setenv LD_LIBRARY_PATH $LD_LIBRARY_PATH\:$PREFIX/lib\:$PREFIX/lib64
setenv PATH $PATH\:$PREFIX/bin
```

Activate conda (at least Python 3 needs to be enabled):

```
module load conda
```

Create environment for additional Python runtime dependencies:

```
conda create --prefix conda-for-wx python=3.7
```

Activate the environment in a specific directory:

```
conda activate /usr/local/usrapps/.../conda-for-wx
```

Install these dependencies:

```
conda install -c anaconda numpy wxpython python-dateutil ply termcolor
```

Get and compile GRASS GIS:

```
tcsh -e ./compile.sh $PREFIX
```

Test:

```
tcsh -e ./test.sh
tcsh -e ./test-thorough.sh
```

## Run


Set the environmental variables:

```
set PREFIX=/usr/local/usrapps/.../bin/
setenv LD_LIBRARY_PATH $LD_LIBRARY_PATH\:$PREFIX/lib\:$PREFIX/lib64
setenv PATH $PATH\:$PREFIX/bin
```

Activate conda and the conda environment:

```
module load conda
conda activate /usr/local/usrapps/.../conda-for-wx
```

Run:

```
grass79 ...
```

## Setup for use

Create a file to be sourced (place it into `$PREFIX`):

```
# This file must be used with "source bin/activate" from tcsh.
# It is not useful for anything to run it directly.
set PREFIX=/usr/local/usrapps/.../bin/
setenv LD_LIBRARY_PATH $LD_LIBRARY_PATH\:$PREFIX/lib\:$PREFIX/lib64
setenv PATH $PATH\:$PREFIX/bin
module load conda
conda activate $PREFIX/../conda-for-wx
```

Create a symlink to the executable to make the command version-independent:

```
ln -s ${PREFIX}bin/grass79 ${PREFIX}bin/grass
```
