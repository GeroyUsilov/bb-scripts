#!/bin/bash

# Check if input file is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <resfile>"
    echo "Example: $0 combinatoric_resfiles/resfile_1.txt"
    exit 1
fi

# Get the resfile path
resfile=$(readlink -f "$1")

# Get the output directory based on the resfile name
resfile_name=$(basename "$resfile" .txt)
output_dir="combinatoric_results/${resfile_name}_output"

# Check if output directory exists
if [ ! -d "$output_dir" ]; then
    echo "Error: Output directory $output_dir does not exist. Please run setup_output_dirs.sh first."
    exit 1
fi

# Copy the resfile to the output directory
cp "$resfile" "$output_dir/"

# Get script directory for absolute paths
SCRIPT_DIR=$(dirname $(dirname $(readlink -f "$0")))

# Loop through all PDB files
for pdb_file in "$SCRIPT_DIR/data/pdb_files"/*.pdb; do
    # Get PDB name without extension
    pdb_name=$(basename "$pdb_file" .pdb)
    
    # Create subdirectory for this PDB
    pdb_dir="$output_dir/$pdb_name"
    mkdir -p "$pdb_dir"
    
    # Copy PDB file to subdirectory
    cp "$pdb_file" "$pdb_dir/"
    
    # Change to PDB subdirectory
    cd "$pdb_dir"
    
    # Run fixbb with the resfile
    $SCRIPT_DIR/scripts/run_fixbb.sh "$(basename $pdb_file)" "$resfile_name.txt"
    
    # Return to output directory
    cd ..
done 