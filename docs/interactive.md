# Running GRASS GIS interactively

## In command line

## With graphical user interface

### Using SSH on Linux, macOS, and other unixes

When connecting using SSH, you need to ask for connection with graphics.
This is done using the `-X` flag of *ssh* or sometimes `-Y` (read the
documentation for your platform):

```sh
ssh login.hpc.ncsu.edu -X
```

Once you start GRASS GIS and the GRASS shell appears, you can start
the graphical user interface (GUI) using the following command
if it does not start automatically (depends on your settings):

```sh
g.gui
```
