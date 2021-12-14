#!/usr/bin/env bash

# Gets version numbers directly from the software on path.

set -o errexit

if [[ $# -ne 1 ]]; then
    echo >&2 "Usage: $0 MODULE_VERSION"
    exit 1
fi

MODULE_VERSION=$1
RECORD_DIR=$(pwd)

METADATA_DIR="$RECORD_DIR/available/$MODULE_VERSION"
METADATA_FILE="$METADATA_DIR/software.yml"

record_software() {
    {
        echo "  - name: $1"
        echo "    version: \"$2\""
        echo "    description: $3"
        echo "    interfaces: $4"
    } >> "$METADATA_FILE"
}

record_python_package() {
    if [[ $# -ne 4 ]]; then
        INTERFACES="Python"
    else
        INTERFACES=$4
    fi

    VERSION=$(python -c "import $2; print($2.__version__)" || echo "")
    record_software "$1" "$VERSION" "$3" "$INTERFACES"
}

echo "software:" > "$METADATA_FILE"

record_software \
    "GRASS GIS" \
    "$(grass --config version)" \
    "GIS, geospatial modeling, analysis, and remote sensing" \
    "Python, command line, GUI"
record_software \
    "PDAL" \
    "$(pdal --version | grep pdal | sed -e "s/.* \([^a-z]\+.[^a-z]\+.[^a-z]\+\) .*/\1/g")" \
    "Point cloud data translation and manipulation" \
    "command line"
record_software \
    "GDAL" \
    "$(gdalinfo --version | sed -e "s/.* \([^a-z]\+.[^a-z]\+.*\),.*/\1/g")" \
    "Raster and vector data translation and manipulation" \
    "command line"
record_software \
    "PROJ" \
    "$(proj 2>&1 | grep Rel | sed -e "s/.* \([^a-z]\+.[^a-z]\+.[^a-z]\+\), .*/\1/g")" \
    "Conversions between cartographic projections" \
    "command line"
record_software \
    "Python" \
    "$(python --version | sed -e "s/.* \([^a-z]\+.[^a-z]\+.[^a-z]\+\)*/\1/g")" \
    "Scripting language" \
    "python, ipython, JupyterLab"

record_python_package NumPy numpy \
    "Multi-dimensional arrays and matrices and mathematical functions"
record_python_package SciPy scipy \
    "Scientific computing and technical computing"
record_python_package pandas pandas \
    "Data analysis and manipulation"
record_python_package scikit-learn sklearn \
    "Machine learning"
record_python_package Matplotlib matplotlib \
    "Plotting"
record_python_package JupyterLab jupyterlab \
    "Computational notebook environment" \
    "GUI in web browser"

record_software \
    "SQLite" \
    "$(python -c "import sqlite3; print(sqlite3.sqlite_version)")" \
    "File-based database" \
    "command line"
