# grass-gis-on-hpc-henry2

Repository for instructions for compiling GRASS GIS on NCSU HPC Henry2

## Steps on Henry2

Set the the prefix variable to be used throughout the workflow:

```
set PREFIX=/usr/local/usrapps/.../bin/
```

```
mkdir $PREFIX
```

Get and compile dependencies:

```
./dependencies.sh $PREFIX
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
conda install -c anaconda numpy wxpython
```

Get and compile GRASS GIS:

```
./compile.sh $PREFIX
```

Test:

```
./test.sh
./test-thorough.sh
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

## Ubuntu 18.04 dependencies for testing

```
apt update -y
# tools for compilation
apt install -y build-essential
# or: apt install -y gcc g++ make
apt install -y wget git cmake tcsh
# GRASS GIS dependencies available at Henry2
apt install -y flex bison zlib1g-dev libpng-dev libgl1-mesa-dev libglu1-mesa-dev libfftw3-dev libcairo-dev python3-six
```
