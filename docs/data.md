# Managing data

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

## Computational region

## GRASS GIS as part of a larger processing workflow

## GRASS GIS as a primary tool used

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

