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

# Path to Rosetta database 
rosetta_db="/software/rosetta-2017.08.59291-el7-x86_64/main/database"

# Path to Rosetta binary 
fixbb_exe="/software/rosetta-2017.08.59291-el7-x86_64/main/source/bin/fixbb.static.linuxgccrelease"

# Run fixbb
$fixbb_exe \
    -s $input_pdb \
    -resfile $resfile \
    -packing:repack_only
    -ex1 \
    -ex2 \
    -use_input_sc \
    -nstruct 10 \
    -linmem_ig 10 \
    -minimize_sidechains \
    -database $rosetta_db \
    -overwrite
    -out:prefix $(echo $resfile | cut -d. -f1)_