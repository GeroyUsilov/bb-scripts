#!/bin/bash

# Input PDB file and resfile
input_pdb=$1
resfile=$2

if [ -z "$input_pdb" ] || [ -z "$resfile" ]; then
    echo "Usage: $0 <input_pdb_file> <resfile>"
    echo "Example: $0 structure.pdb my_resfile.txt"
    exit 1
fi

# Check if files exist
if [ ! -f "$input_pdb" ]; then
    echo "Error: Input PDB file $input_pdb not found"
    exit 1
fi

if [ ! -f "$resfile" ]; then
    echo "Error: Resfile $resfile not found"
    exit 1
fi

# Path to Rosetta database (you'll need to modify this)
rosetta_db="/path/to/rosetta/main/database"

# Path to Rosetta binary (you'll need to modify this)
fixbb_exe="/path/to/rosetta/main/source/bin/fixbb.default.linuxgccrelease"

# Run fixbb
$fixbb_exe \
    -s $input_pdb \
    -resfile $resfile \
    -ex1 \
    -ex2 \
    -use_input_sc \
    -nstruct 10 \
    -linmem_ig 10 \
    -minimize_sidechains \
    -database $rosetta_db \
    -overwrite