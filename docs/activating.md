# Activating GRASS GIS

## Get access

Ask OIT HPC to be added to the gis group.

## Activate

Append the geospatial modules to list of available modules:

```sh
module use --append /usr/local/usrapps/geospatial/modulefiles
```

Load the module:

```sh
module load grass
```

This loads the default version of GRASS GIS on Henry2.

You can see what is currently the default version and what are the other versions
and software available with:

```sh
module avail
```

See an overview of all available versions in [Available Versions](available.md).

## Use specific version for reproducibility

To use a specific version to ensure reproducibility both in terms
of using always using the same version on Henry2 and also being
able to easily identify what version you used in the past,
load a specific version instead of relying on the default version.

To load a specific version, use:

```sh
module load grass/7.8-2021-06-24
```

For publication related-reproducibility and citation,
get additional version information about the
GRASS version you are using and to get specifics by calling `g.version -g`.
Additionally, see the specifics of the Henry2 installation in the
[available](../available) directory of this repository.

## See also

- [Available Software](software.md) for all installed software
- [Available Versions](available.md) for all installed versions of GRASS GIS and available shortcuts

Next: [Running jobs](jobs.md)
