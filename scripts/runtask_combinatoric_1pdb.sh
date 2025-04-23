#!/bin/bash
# Check if input file and PDB file are provided
if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: $0 <resfile> <pdb_file>"
    echo "Example: $0 combinatoric_resfiles/resfile_1.txt data/pdb_files/1abc.pdb"
    exit 1
fi

# Get the resfile path
resfile=$(readlink -f "$1")

# Get the PDB file path
pdb_file=$(readlink -f "$2")

# Get script directory for absolute paths
SCRIPT_DIR="$SLURM_SUBMIT_DIR"

# Get the output directory based on the resfile name
resfile_name=$(basename "$resfile" .txt)
output_dir="$SCRIPT_DIR/combinatoric_results/${resfile_name}_output"

# Get PDB name without extension
pdb_name=$(basename "$pdb_file" .pdb)

# Check if zipped archive exists
if [ ! -f "$SCRIPT_DIR/combinatoric_results/${resfile_name}_output.tar.gz" ]; then
    echo "Error: Archive file ${resfile_name}_output.tar.gz does not exist."
    exit 1
fi

# Extract the archive
cd "$SCRIPT_DIR/combinatoric_results"
tar -xzf "${resfile_name}_output.tar.gz"

# Check if output directory exists after extraction
if [ ! -d "$output_dir" ]; then
    echo "Error: Output directory $output_dir does not exist after extraction."
    exit 1
fi

# Create scores directory if it doesn't exist
scores_dir="$SCRIPT_DIR/combinatoric_results/scores"
mkdir -p "$scores_dir"

# Copy the resfile to the output directory
cp "$resfile" "$output_dir/"

# Clean up any existing results for this PDB
if [ -d "$output_dir/$pdb_name" ]; then
    rm -rf "$output_dir/$pdb_name"
fi

# Create subdirectory for this PDB
pdb_dir="$output_dir/$pdb_name"
mkdir -p "$pdb_dir"

# Copy PDB file to subdirectory
cp "$pdb_file" "$pdb_dir/"

# Change to PDB subdirectory
cd "$pdb_dir"

# Run fixbb with the resfile
$SCRIPT_DIR/scripts/run_fixbb.sh "$(basename $pdb_file)" "$output_dir/$resfile_name.txt"

# After processing, copy score file to scores directory
if [ -f "$pdb_dir/score.sc" ]; then
    cp "$pdb_dir/score.sc" "$scores_dir/${resfile_name}_${pdb_name}_score.sc"
fi

# Create tar.gz archive of the output directory
cd "$SCRIPT_DIR/combinatoric_results"
tar -czf "${resfile_name}_output.tar.gz" "${resfile_name}_output"

# Remove the original output directory
rm -rf "${resfile_name}_output"

echo "Processing completed for $pdb_name with resfile $resfile_name"