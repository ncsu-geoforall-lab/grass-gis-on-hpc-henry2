# Running jobs with GRASS GIS

## Running a single job calling a GRASS module

Always create a new mapset (with -c flag). In this example, we compute slope raster map
in a new mapset called `new_mapset` based on raster `DEM` from mapset `PERMANENT` and
then we export it to a tif file, in this case it assumes it's a large file.
See r.out.gdal for other options. The tif file should be exported to a scratch folder
(`/share/...`). This is all running as a single process, hence `-n 1`.

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

grass79 -c /path/to/grassdata/albers/new_mapset --exec r.slope.aspect elevation=DEM@PERMANENT slope=slope
grass79 /path/to/grassdata/albers/new_mapset --exec r.out.gdal input=slope output=/share/path/to/slope.tif type=Float32 createopt="COMPRESS=LZW,PREDICTOR=3,BIGTIFF=YES"
```
