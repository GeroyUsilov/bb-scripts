#!/bin/bash

# Check if input file is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <resfile>"
    echo "Example: $0 combinatoric_resfiles/resfile_1.txt"
    exit 1
fi

# Get the resfile path
resfile=$(readlink -f "$1")

# Get script directory for absolute paths
SCRIPT_DIR="$SLURM_SUBMIT_DIR"

# Get the output directory based on the resfile name
resfile_name=$(basename "$resfile" .txt)
output_dir="$SCRIPT_DIR/combinatoric_results/${resfile_name}_output"

# Check if output directory exists
if [ ! -d "$output_dir" ]; then
    echo "Error: Output directory $output_dir does not exist. Please run setup_output_dirs.sh first."
    exit 1
fi

# Create scores directory if it doesn't exist
scores_dir="$SCRIPT_DIR/combinatoric_results/scores"
mkdir -p "$scores_dir"

# Copy the resfile to the output directory
cp "$resfile" "$output_dir/"

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
    $SCRIPT_DIR/scripts/run_fixbb.sh "$(basename $pdb_file)" "$output_dir/$resfile_name.txt"
    
    # Return to output directory
    cd ..
done

# After processing all PDBs, copy score files to scores directory
for pdb_dir in "$output_dir"/*/; do
    if [ -d "$pdb_dir" ]; then
        pdb_name=$(basename "$pdb_dir")
        # Find and copy score file with new naming format
        if [ -f "$pdb_dir/score.sc" ]; then
            cp "$pdb_dir/score.sc" "$scores_dir/${resfile_name}_${pdb_name}_score.sc"
        fi
    fi
done

# Create tar.gz archive of the output directory
cd "$SCRIPT_DIR/combinatoric_results"
tar -czf "${resfile_name}_output.tar.gz" "${resfile_name}_output"

# Remove the original output directory
rm -rf "${resfile_name}_output" 