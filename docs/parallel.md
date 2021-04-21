# Running parallel processes

## One node

### Modules which allow parallel processing

Some core modules, e.g., r.sun, r.sim.water, or v.surf.rst, and some addon modules, e.g.,
modules r.sun.hourly and r.sun.daily, allow parallel processing internally,
i.e., are parallelized.

These modules usually have a parameter called `nprocs` which determines how many cores
it will use for the parallel part of the computation. All core GRASS GIS modules use only
one core by default to ensure they don't use more resources than expected
(if you think that's not the case, open an issue).

To take advantage of this parallelism, you need to request one node, exclusive use of that node,
and one process per node using:

```sh
#BSUB -n 1
#BSUB -x
#BSUB -R span[ptile=1]
```

Many modules also allow you to set memory they will using using parameter `memory`
(often in MiB).

```sh
#BSUB -n 1
#BSUB -x
#BSUB -R span[ptile=1]
#BSUB -R "rusage[mem=50GB]"
```

For those modules which don't allow specifying memory, you need to consult
the documentation and test the computation with your data so that you know
the memory requirements. Most modules keep the memory requirements minimal,
but often raster modules load at least one row of data into memory.
Some modules need to load all data into memory.

### The GridModule Python API

This example shows how to rasterize vector layer by in parallel by tiling it (within 1 node).
Adjust this script (tiling width/height/overlap based on region and cores,
use different module and parameters)
and then save as tiling.py in your home folder.

```python
import sys
from grass.pygrass.modules.grid.grid import GridModule

# adjust width, height as needed given the region
# and number of processes
def main(module, params, overlap):
    mapset_prefix = 'tmp' + params['output'].replace('_', '')
    grd = GridModule(module,
                     width=161200, height=6600, overlap=overlap,
                     processes=16, split=False, mapset_prefix=mapset_prefix,
                     overwrite=True, **params)
    grd.run()


if __name__ == '__main__':
    # check for number of parameters
    # replace 2 with something else
    if len(sys.argv) - 1 != 2:
        sys.exit()

    args = sys.argv[1:]
    # specific params for running module
    params = {}
    params['input'] = args[0]
    params['output'] = args[1]
    params['memory'] = 2000
    params['use'] = 'val'
    overlap = 0
    module = 'v.to.rast'

    main(module, params, overlap)
```

In the BSUB script call this script with parameters (in this case input vector name and output raster name
```sh
grass /share/path/to/grassdata/albers/mymapset --exec python ~/tiling.py roads roads_rasterized
```
Make sure the number of cores you specify match the number of processes in the script.
Review [GridModule documentation](https://grass.osgeo.org/grass78/manuals/libpython/pygrass.modules.grid.html) and the documentation of the specific module you plan to use. Note that not all algorithms are suitable for this type of parallelization (e.g. flow accumulation can't be computed like that).

If something goes wrong during the computation, there will remain temporary mapsets in your location, please remove them before trying again.

GridModule doesn't care about memory, if the processes require more memory than the node has available, it will crash. See if the specific GRASS module has memory option to control it, or request node with higher memory.


## Multiple nodes
