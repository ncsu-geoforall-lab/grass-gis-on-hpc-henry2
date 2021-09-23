# Managing data

## GRASS GIS as part of a larger workflow

When you are using GRASS GIS as part of a larger workflow in R or Python,
you may want to just create the GRASS location in your script right before
you import data there and start processing. Once the processing is done, you export
the data and delete the location.

## GRASS GIS as a primary tool used

If you are doing a lot of processing in GRASS GIS or it is your primary geospatial
processing tool, you probably keep the data in GRASS Location or multiple Locations.
On Henry2, this workflow is best achieved by using Research Storage for the data,
but it can be also achieved by simply copying the data around.
In any case, you create a separate mapset for your processing and multiple
mapsets for parallel processing and you delete these mapsets once you are finished
post-processing or aggregating the data in these mapsets.

## Preparing the data locally

You can prepare a GRASS Location locally, create an archive (e.g., ZIP), and upload to HPC
or you can use the GeoTIFF -> GRASS GIS -> GeoTIFF workflow, i.e., what you bring to and
out of HPC is GeoTIFF rather than the GRASS Location and you create a one on HPC and
delete it later.

The version (the build to be exact) of GRASS GIS you will use locally likely uses the
new ZSTD compression by default, but GRASS on HPC does not support it yet.
To be able to transfer the dataset as is to HPC, you need to change the compression on
your local machine. It is a combination of setting environmental variables and
running r.compress module. The [r.compress manual](https://grass.osgeo.org/grass78/manuals/r.compress.html#applying-zlib-compression)
covers the steps how to change to ZLIB compression.

## Importing data to the GRASS GIS database

Similarly to loading or importing data into R, Python NumPy, or PostgreSQL,
you need to import or link data into GRASS GIS spatial database in order
to use them inside GRASS GIS.

Import the GeoTIFF using:

```sh
r.import input=/.../dem.tif output=dem
```

The corresponding operation in GUI:

```text
File > Import raster data > Import of common formats... [r.import]
```

## Exporting data from the GRASS GIS database

Export a GeoTIFF using:

```sh
r.out.gdal input=dem output=/.../dem.tif
```

## Sharing a database between different users

Often, it is advantageous to share data computed in GRASS GIS by one user among other users working on the same project.
On some systems, it is possible to have one GRASS GIS spatial database directory or one location (directory in the database directory)
shared and used by more than one person. Given how the users, user groups, and permission work on Henry2, this not possible
to achieve using a set of permissions on the directories and a different approach involving symlinks and sharing parts of the database
needs to be employed.

### Location based on another user's location

Let's say another user created a location `albers` in a Research Storage called FUTURES. The path to this directory is:

```text
/rsstu/users/r/rkmeente/FUTURES/grassdata/albers/
```

Now, you want to have a location which share the CRS definition and data in the PERMAMENT mapset.
To do that you will need to create an empty directory for the location and link the PERMANENT mapset
using the following steps.

In the directory you want to have your GRASS GIS spatial database do:

```sh
mkdir grassdata
```

Then, create the empty directory for the location called `albers` do:

```sh
mkdir grassdata/albers
```

Then, link the PERMANENT mapset from the other user's location to yours
using a symlink:

```sh
ln -s /rsstu/users/r/rkmeente/FUTURES/grassdata/albers/PERMANENT/ grassdata/albers/
```

The resulting directory tree should look like this:

```sh
$ tree grassdata/
grassdata/
└── albers
    └── PERMANENT -> /rsstu/users/r/rkmeente/FUTURES/grassdata/albers/PERMANENT/
```

Now, test if everything works by creating a new mapset in this location:

```sh
grass grassdata/albers/scenario1 -c -e
```

You should now see data in the other user's PERMANENT mapset. Try listing all available rasters
(it will show those from PERMANENT and nothing for your empty mapset):

```sh
grass grassdata/albers/scenario1 --exec g.list type=raster -p
```

In this workflow, there is only one PERMANENT mapset and the original user is managing it. Any changes in that mapset
will influence you as well. This is usually desired because when the other user adds more data, this data is available
to your right away. However, the other user should be aware of you using their PERMANENT mapset this way in case
some changes in CRS, name, or directory structure are needed.

All the mapsets you create in this location are yours and yours only. The other users may access them depending on unix permission,
but from the point of view of GRASS GIS there is nothing else shared except for PERMAMENT between your location
and the location of the other user. This means, for example, that a mapset in your location can have the same name
as a mapset in the other user's location and you don't have to be worried about stepping on each other toes when doing parallel computing.

## Computational region

For most formats, the data is imported in their full extend.
However, the subsequent computations use extend and resolution from the
(current) computational region if extend or resolution are needed.
Most raster operations depend on the computational region while
most vector operations do not.
Sometimes, the import can be limited to only the current computational region.
Export is usually limited to the current computational region only for rasters.

The computational region needs to be set before the computation begins
and it is associated with one mapset. However, there are tools to change
computational region only for part of the computation. This is used for
parallelizing or optimizing the computations or for testing.

For large datasets, computational region allows to perform the computation for only
part of the dataset. The individual results can be patched together later.

It is generally a good idea to make the code region-independent as much as possible,
i.e., push the computation region settings high in the code structure.
However, for running a job, the computational region should be somewhere
otherwise it will rely on whatever is the (last set) computational region in the
current mapset.

## Using local scratch space for temporary data

### Running a single job
If you are processing a large number of temporary files with GRASS GIS, it can be useful to write the   
temporary files to local scratch space on the compute node (can decrease run time). In your  
[job submission script](https://github.com/ncsu-geoforall-lab/grass-gis-on-hpc-henry2/blob/main/docs/jobs.md#running-a-single-job-calling-a-grass-module) you will need to add the following code, e.g.:  

```tcsh
#!/bin/tcsh
#BSUB -n 1
#BSUB -W 48:00
#BSUB -R span[hosts=1]
#BSUB -oo comp1_out
#BSUB -eo comp1_err
#BSUB -J comp1

#########   LOAD MODULES   #########
module use --append /usr/local/usrapps/geospatial/modulefiles/
module load grass

#########   CODE TO WRITE TO LOCAL SCRATCH   #########
# Set the path for the temporary file directory
# $LSB_JOBID will reference the job ID of the submission
setenv TMPDIR /scratch/$LSB_JOBID

# Create the directory 
mkdir -p /scratch/$LSB_JOBID/grassdata/albers

# Link the PERMANENT mapset of interest to the temporary file directory using a symlink
ln -s /rsstu/users/r/rkmeente/FUTURES/grassdata/albers/PERMANENT/ /scratch/$LSB_JOBID/grassdata/albers/

# The resulting directory tree should look something like this:
tree /scratch/$LSB_JOBID/grassdata/
/scratch/65834/grassdata/
└── albers
    └── PERMANENT -> /rsstu/users/r/rkmeente/FUTURES/grassdata/albers/PERMANENT/

#########   GRASS CODE   #########
# Run some GRASS code, e.g. a python script:
grass --tmp-mapset /scratch/$LSB_JOBID/grassdata/albers --exec python script.py 


#########   CODE TO REMOVE TEMPORARY FILE DIRECTORY   #########
# Remove the temporary files and directory
rm -fr /scratch/$LSB_JOBID
```

### Running a parallel job on multiple nodes using pynodelauncher
Sometimes you will create a large number of temporary files in GRASS GIS using a [parallel job
across multiple nodes with *pynodelauncher*.](https://github.com/ncsu-geoforall-lab/grass-gis-on-hpc-henry2/blob/main/docs/parallel.md#multiple-nodes)
In this use case, you will need to create a wrapper script to write to local scratch.  

Let's say you have the following submission script:  

```tcsh
#!/bin/tcsh
#BSUB -n 11
#BSUB -W 72:00
#BSUB -R "rusage[mem=40GB]"
#BSUB -R "span[ptile=1]"
#BSUB -oo grass_tasks_out
#BSUB -eo grass_tasks_err
#BSUB -J grass_tasks

module use --append /usr/local/usrapps/geospatial/modulefiles/
module load grass
module load PrgEnv-intel

mpiexec python -m mpi4py -m pynodelauncher .../scripts/tasks.txt
```

The `tasks.txt` will need to contain the list of wrapper script commands to be executed in parallel by *pynodelauncher*, e.g.:

```txt
./wrapper_script.csh 1 2
```

where `1` and `2` are arguments to the code you are running.  

`wrapper_script.csh` needs to contain the following code to write temporary files to local scratch space on the compute node:

```tcsh
#!/bin/tcsh

# Set the path for the temporary file directory
# $LSB_JOBID will reference the job ID of the submission
setenv TMPDIR /scratch/$LSB_JOBID

# Create the directory 
mkdir -p /scratch/$LSB_JOBID/grassdata/albers

# Link the PERMANENT mapset of interest to the temporary file directory using a symlink
ln -s /rsstu/users/r/rkmeente/FUTURES/grassdata/albers/PERMANENT/ /scratch/$LSB_JOBID/grassdata/albers/

# The resulting directory tree should look something like this:
tree /scratch/$LSB_JOBID/grassdata/
/scratch/65834/grassdata/
└── albers
    └── PERMANENT -> /rsstu/users/r/rkmeente/FUTURES/grassdata/albers/PERMANENT/

# Run some GRASS code, e.g. a python script:
grass --tmp-mapset /scratch/$LSB_JOBID/grassdata/albers --exec python script.py $argv:q

# Remove the temporary files and directory
rm -fr /scratch/$LSB_JOBID
```

Note that `$argv:q` is required to pass the arguments from the `tasks.txt` file to GRASS code you are submitting.  

### Increasing the open file limit

If you have a large number of temporary files, you may also have issues with the number of files  
that can be open at once. In order to increase the open file limit for a particular job (first check  
with HPC administrators what the hard limit is), you can add the following line of code to either the   
submission script (for running a single job) or to the wrapper script (`wrapper_script.csh`) for  
running a parallel job on multiple nodes using *pynodelauncher*:  

```sh
# Increase the open file limit to 8192
limit descriptors 8192
```

Note that this code will need to be added *before* executing the GRASS code!  

