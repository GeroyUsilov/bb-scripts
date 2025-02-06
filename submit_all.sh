#!/bin/bash

# Check for directory argument
if [ $# -ne 1 ]; then
    echo "Usage: $0 <directory>"
    exit 1
fi

directory=$1

# Submit a job for each PDB file
for pdb in "$directory"/*.pdb; do
    if [ -f "$pdb" ]; then
        pdb_name=$(basename "$pdb")
        echo "Submitting job for $pdb_name"
        sbatch run_amber.slurm "$directory" "$pdb_name"
    fi
done