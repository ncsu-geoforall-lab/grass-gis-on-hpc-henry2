# Installing Addons

GRASS GIS has an official repository with addons from where additional tools can be installed.
Other tools can be installed from downloaded files or from individual repositories such as Git repositories on GitHub.

The new tools are installed by the _g.extension_ tool. Many addon tools are in Python, but some are C and C++.
The addons are compiled during installation. For addons which are using C++ or modern C such as C99,
you will need to setup a recent GCC version by loading the _gcc_ module on HPC (9.3.0 is what the current build of GRASS GIS is using).

```sh
module load gcc/9.3.0
```

You also need to have the same versions of standard C++ libraries the dependencies are using
(such as GDAL using the right libstdc++). For this, load conda:

```sh
module load conda
```

The order is important and only after this, you can load the version of GRASS GIS you are using:

```sh
module load grass/{version}
```

This will allow you to compile (and thus install) these new addons using:

```sh
grass --tmp-location XY --exec g.extension {name-of-addon}
```

The addons are installed into your home directory. This don't take much space, but there is only
one version of installed addon for each major version of GRASS GIS (e.g., one for v7 and one for v8).
Consequently, when you start using an updated version of GRASS GIS (a different release or a development
version from a different day), you will need to recompile the C and C++ addons you have installed.
All installed addons can be recompiled (reinstalled) using _g.extension.all_:

```sh
grass --tmp-location XY --exec g.extension.all
```

This will install recent versions of all addons from the official repository.
If you installed some tools from other sources, you will need to reinstall them in the same way you
originally installed them.

Next: [Compiling and installing](install.md)
