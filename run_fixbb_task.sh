#!/bin/sh
# Takes 3 arguments: $1=pdb_file, $2=resfile, $3=output_dir

# Get absolute path to the run_fixbb.sh script
script_dir=$(dirname $(readlink -f "$0"))
fixbb_script="${script_dir}/run_fixbb.sh"

# Get the base names for creating job directory
pdb_base=$(basename "$1" .pdb)
resfile_base=$(basename "$2" .txt)
output_dir="$3/${resfile_base}"

# Create directory for this specific resfile
mkdir -p "$output_dir"

# Create symbolic links to input files in the output directory
ln -s "$1" "$output_dir/$(basename $1)"
ln -s "$2" "$output_dir/$(basename $2)"

# Change to output directory
cd "$output_dir"
echo "About to run fixbb.sh from: ${fixbb_script}"
# Run the fixbb script with the symlinked files and the absolute path
"${fixbb_script}" "$(basename $1)" "$(basename $2)"

# Output some diagnostics
echo "Processed: $resfile_base on $(hostname) at $(date)"