## Setup in an Interactive Shell

Request an interactive job:

```bash
bsub -Is -n 1 -R "rusage[mem=1GB]" -W 30 bash
```

Load HPC module for GRASS GIS:

```bash
module use --append /usr/local/usrapps/geospatial/modulefiles
module load grass
grass --version
```

In this example, we will go through a case where input data is the same for all
tasks, so we will do the inital steps once, separatelly from the subsequent processing.

Create project (aka location):

```bash
grass -c EPSG:3358 -e project_EPSG_3358
```

Start an interactive shell with GRASS session:

```bash
grass --text project_EPSG_3358/PERMANENT/
```

Generate a raster with random cell values
(this step would be usually an import of input data):

```bash
g.region rows=1000 cols=1000
r.surf.random output="data"
```

Two exits, one for the GRASS session and one for the interactive job,
to finish this job:

```bash
exit
exit
```

## Prepare a Processing Script

```bash
nano grass_processing.py
```

Use Alt+I to disable auto-indent.

```python
import subprocess
import sys

# Asks GRASS GIS where its Python packages are.
sys.path.append(
    subprocess.check_output(["grass", "--config", "python_path"], text=True).strip()
)

# Imports the GRASS GIS packages we need.
import grass.script as gs
import grass.script.setup  # This line is needed only for v8.2 and older.

def main():
    directory = sys.argv[1]
    window_size = sys.argv[2]

    # Starts a GRASS session and uses its context manager API.
    with grass.script.setup.init(f"{directory}/project_EPSG_3358"):
        print(f"r.neighbors with window_size {window_size}")
        gs.run_command(
            "r.neighbors",
            input="data",
            output=f"average_{window_size}",
            method="average",
            size=window_size,
            flags="c",
            nprocs=1,
            memory=300,
        )

if __name__ == "__main__":
    main()
```

## Get pynodelauncher

We will use _pynodelauncher_ to submit a job for multiple nodes
(distributed memory job) without direct use of MPI.

Currently, the _pynodelauncher_ tool needs to be installed using _pip_
with the relevant modules loaded:

```bash
module use --append /usr/local/usrapps/geospatial/modulefiles
module load gcc
module load grass
module load PrgEnv-intel
pip install git+https://github.com/ncsu-landscape-dynamics/pynodelauncher.git
```

## Generate Commands to Execute

```bash
nano generate_commands.py
```

Use Alt+I to disable auto-indent.

```python
import sys

directory = sys.argv[1]
with open(f"{directory}/commands.txt", "w") as commands:
    for i in range(41, 9, -2):
        print(f"python {directory}/grass_processing.py {directory} {i}", file=commands)
```

```bash
python generate_commands.py $(pwd)
```

```bash
head commands.txt
```

## Submit a Job

```bash
nano grass_job.sh
```

```bash
#!/bin/bash
#BSUB -n 10
#BSUB -R rusage[mem=5GB]
#BSUB -R span[ptile=5]
#BSUB -W 40:00
#BSUB -oo grass_out
#BSUB -eo grass_err
#BSUB -J grass

module use --append /usr/local/usrapps/geospatial/modulefiles
module load grass
module load PrgEnv-intel

mpiexec python -m mpi4py -m pynodelauncher commands.txt
```

## Check the Results Interactively

```bash
bsub -Is -n 1 -R "rusage[mem=1GB]" -W 30 bash
```

```bash
module use --append /usr/local/usrapps/geospatial/modulefiles
module load grass
```

```bash
grass project_EPSG_3358/PERMANENT/ --text
```

```bash
g.list raster
r.univar average_11
r.univar average_41
```

```bash
exit
exit
```
