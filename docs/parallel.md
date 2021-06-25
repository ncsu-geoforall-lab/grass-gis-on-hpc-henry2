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

### Modules which don't work with GridModule API

Modules which don't run in parallel themselves and don't work with GridModule API,
e.g., because of multiple raster outputs, may have a special parallelized wrapper
in GRASS Addons repository. For example, r.mapcalc is wrapped as r.mapcalc.tiled.

## Multiple nodes

Executing on multiple nodes requires a special approach. The best approach
for GRASS GIS on Henry2 is to distribute separate tasks (processes) on multiple
nodes using MPI. The _pynodelauncher_ program provides a way how to easily
automate creation of these jobs by providing an interface focused on independent
processes while using MPI in the background. See the _pynodelauncher_ documentation
for more information and use the following to set it up (if you already set it up
based on the documentation, you can skip this step):

```sh
module use --append /usr/local/usrapps/geospatial/modulefiles/
module load grass
module load PrgEnv-intel

pip install git+https://github.com/ncsu-landscape-dynamics/pynodelauncher.git
```

Prepare your data in a GRASS location. Here we will refer to this location as
`.../grassdata/project` where `.../grassdata/` would be a full path to the
location and `project` the name of the location.
The `...` part may be your Scratch Space or Research Storage
(research project directory).

Here, we will also assume that the portion of the analysis which should run in parallel
for many different subsets of the data is in a Python script called `single_task.py`.
We will refer to the full path to this script as `.../scripts/single_task.py`.

### Process which creates files

This applies to processes which create non-spatial data in files and geospatial data
exported from GRASS GIS.

Prepare a file with list of commands to be executed in parallel by _pynodelauncher_.
We will call this file `tasks.txt` because it contains all the small tasks in our big
job we are submitting to the BSUB system.

It is important that these tasks are independent and can run in parallel to each other.
The best way how to achieve that in GRASS GIS is to run each task in a separate mapset.
Thus, you need to create a mapset for each task, execute your script, and delete the
mapset at the end. Creating and deleting a mapset is done automatically when you use
the `--tmp-mapset` option, so you just need to use it together with path to the
location, `--exec` option and path to your script.

```sh
grass --tmp-mapset .../grassdata/project --exec python .../scripts/single_task.py output=out_1.txt coordinates=518205,3485625
grass --tmp-mapset .../grassdata/project --exec python .../scripts/single_task.py output=out_2.txt coordinates=518235,3485625
grass --tmp-mapset .../grassdata/project --exec python .../scripts/single_task.py output=out_3.txt coordinates=518265,3485625
...
```

When you have prepared this file, by hand, in a spreadsheet, or, ideally, by generating
it with a script, you are ready to use with _pynodelauncher_ in a BSUB script.

### Process which creates geospatial outputs

If you want to post-process the outputs from individual tasks in GRASS GIS,
you can't use `--tmp-mapset`. Instead, you need to control the creation and deletion
of the temporary mapsets yourself.

To create a mapset, you can use `-c` option and to delete it later, you can use
the standard `rm` command. The `-c` option can be used together with `--exec`.
However, you will need to execute the `rm` command(s) only later, after you gather
the data from the individual mapsets. The `tasks.txt` file may look like this:

```sh
grass -c .../grassdata/project/temp_1 --exec python .../scripts/single_task.py coordinates=518265,3485625
grass -c .../grassdata/project/temp_2 --exec python .../scripts/single_task.py coordinates=518235,3485625
grass -c .../grassdata/project/temp_3 --exec python .../scripts/single_task.py coordinates=518265,3485625
...
```

Now you can get ready to submit a job (see the sections below).

After your job executes and you gather the data from all temporary mapsets,
remember to delete them with something like:

```sh
# After you are done with the temporary mapsets
# Safer. You may want to generate these too.
rm -r .../grassdata/project/temp_1
rm -r .../grassdata/project/temp_2
rm -r .../grassdata/project/temp_3
...
```

Or alternatively:

```sh
# After you are done with the temporary mapsets
# Simpler, but may delete more than you expect.
rm -r .../grassdata/project/temp_*
...
```

### Submitting job

The BSUB script needs to include the `pynodelauncher` program call
which is done trough `mpiexec`, `python`, and the _mpi4py_ package.
The `tasks.txt` file is provided as a parameter
at the end of the whole call of the `pynodelauncher` program.
Here, we assume your `tasks.txt` file is in directory `.../scripts`.
The complete call putting all these together is:

```sh
mpiexec python -m mpi4py -m pynodelauncher .../scripts/tasks.txt
```

For this to work, you need to load HPC modules for both GRASS GIS and MPI
as when installing `pynodelauncher`. A more complete usage then is:

```sh
module use --append /usr/local/usrapps/geospatial/modulefiles/
module load grass
module load PrgEnv-intel

mpiexec python -m mpi4py -m pynodelauncher .../scripts/tasks.txt
```

Often, the modules in `single_task.py` will have significant memory requirements,
esp., because you will want to take advantage of fast in-memory processing
if it available. Consequently, you need to ask for specific memory amount,
e.g., `"rusage[mem=40GB]"` in the BSUB configuration. If that's requirement for one
`single_task.py` run, then you need to use also `"span[ptile=1]"` to have just
one script on one node (since the memory is requested for a node). If the memory
you set is enough for two parallel runs of `single_task.py`, then
you use `"span[ptile=2]"`, etc.

Here is the example BSUB script with the assumptions made above:

```sh
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

### Testing the workflow locally

If you want, you can actually test the tasks with the _pynodelauncher_
locally on your machine as opposed to HPC.
In standard Python installations, _pynodelauncher_ can be installed
using the instructions in the readme of its GitHub repository.

Alternatively, you can try to run the individual commands in a file
using _GNU parallel_ (which is easy to install on Linux machines):

```sh
parallel < tasks.txt
```

Obviously, you need to select a really small subset of your data,
i.e., small computational region and just a couple of commands in the
`tasks.txt` file.
Testing the rest of the workflow, should be easy as long as you made it adaptable
to a subset of data.
