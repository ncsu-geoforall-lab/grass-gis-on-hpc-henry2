# Running jobs with GRASS GIS
## Running a single job calling a GRASS module
Always create a new mapset (with -c flag). In this example we compute slope and aspect raster maps in a new mapset called `newmapset` based on raster `DEM` from mapset `PERMANENT`. This is a single process.

```tcsh
#!/bin/tcsh 
#BSUB -n 1
#BSUB -W 48:00
#BSUB -R span[hosts=1]
#BSUB -oo comp1_out
#BSUB -eo comp1_err
#BSUB -J comp1

module use --append /usr/local/usrapps/gis/modulefiles/
module load grass/79

grass -c /path/to/grassdata/albers/newmapset --exec r.slope.aspect elevation=DEM@PERMANENT slope=slope aspect=aspect
```
