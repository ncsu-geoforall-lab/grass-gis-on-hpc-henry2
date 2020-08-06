# Running parallel processes

## One node

### Modules which allow parallel processing

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
