# GRASS GIS on HPC Henry2

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.4973732.svg)](https://doi.org/10.5281/zenodo.4973732)

This is a repository with instructions for using and compiling GRASS GIS
on NC State University's HPC Henry2.

## Using GRASS GIS

These are instructions for users of Henry2 on how to run GRASS GIS.
See [docs](docs) for a complete guide.

## Quick start

Activate and run GRASS GIS (as of June 2021, this works on Henry2 as is):

```bash
module use --append /usr/local/usrapps/gis/modulefiles
module load grass/79
grass
```

See [Activating](docs/activating.md) for more details on getting
the GRASS GIS version you want.

## Compiling GRASS GIS

If you maintain a GRASS GIS installation on Henry2 or want a custom
(new, old, or modified) version of GRASS GIS,
follow the [Install](docs/install.md) guide.

## Support

- Question related to GRASS GIS on NC State's Henry2 can be sent to
  Vaclav (Vashek) Petras <vpetras@ncsu.edu>.
- Extended support and support for 3rd parties is provided by
  [Center for Geospatial Analytics](https://cnr.ncsu.edu/geospatial/engage/service-center/).
- General HPC support at NC State University is provided by OIT.

## Authors

- Vaclav Petras, Center for Geospatial Analytics, North Carolina State University
- Anna Petrasova, Center for Geospatial Analytics, North Carolina State University
