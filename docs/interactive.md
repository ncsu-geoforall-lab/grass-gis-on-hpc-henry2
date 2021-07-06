# Running GRASS GIS interactively

## In command line

## With graphical user interface

### Using SSH on Linux, macOS, and other unixes

When connecting using SSH, you need to ask for connection with graphics.
This is done using the `-X` flag of _ssh_ or sometimes `-Y` (read the
documentation for your platform):

```sh
ssh login.hpc.ncsu.edu -X
```

Start GRASS with:

```sh
module use --append /usr/local/usrapps/geospatial/modulefiles/
module load grass
grass /path/to/grassdata/my_location/my_mapset
```

Once you start GRASS GIS and the GRASS shell appears, you can start
the graphical user interface (GUI) using the following command
if it does not start automatically (depends on your settings):

```sh
g.gui
```

Do not run any computations on the login node.
