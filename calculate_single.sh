#!/bin/bash
set -e

# Function to print error messages
error_exit() {
    echo "ERROR: $1" >&2
    exit 1
}

# Check input arguments
if [ $# -ne 2 ]; then
    error_exit "Usage: $0 <directory_path> <pdb_filename>"
fi

directory_path="$1"
pdb_filename="$2"

# Validate inputs
if [ ! -d "$directory_path" ]; then
    error_exit "Directory $directory_path does not exist"
fi

pdb_path="${directory_path}/${pdb_filename}"
if [ ! -f "$pdb_path" ]; then
    error_exit "PDB file $pdb_path does not exist"
fi

# Extract base names
dir_name=$(basename "$directory_path")
pdb_base=$(basename "$pdb_filename" .pdb)
output_prefix="${dir_name}_${pdb_base}"

# Create working directory with parents if needed
work_dir="${directory_path}/${output_prefix}_amber"
mkdir -p "$work_dir"

# Ensure we're in working directory before any operations
cd "$work_dir" || error_exit "Failed to change to working directory"

# Setup log file
log_file="${output_prefix}_calculation.log"
echo "AMBER Energy Calculation - $(date)" > "$log_file"
echo "Processing: $pdb_path" >> "$log_file"
echo "----------------------------------------" >> "$log_file"

# Run pdb4amber
echo "Running pdb4amber..." | tee -a "$log_file"
pdb4amber -i "$pdb_path" -o "${output_prefix}_processed.pdb" >> "$log_file" 2>&1 || {
    error_exit "pdb4amber failed on $pdb_filename"
}

# Create and run tleap
echo "Running tleap..." | tee -a "$log_file"
cat > "${output_prefix}_leap.in" << EOF
source leaprc.protein.ff14SB
source leaprc.water.tip3p
mol = loadpdb ${output_prefix}_processed.pdb
check mol
saveamberparm mol ${output_prefix}.prmtop ${output_prefix}.inpcrd
savepdb mol ${output_prefix}_final.pdb
quit
EOF

tleap -f "${output_prefix}_leap.in" >> "$log_file" 2>&1 || {
    error_exit "tleap failed on $pdb_filename"
}

# Run energy calculation
echo "Running sander..." | tee -a "$log_file"
cat > "${output_prefix}_min.in" << EOF
Single point energy calculation
 &cntrl
   imin=5, ntb=0, maxcyc=0, cut=999.0,
   ntpr=1, ntwx=0, ntwe=0, ntwr=0
 /
EOF

sander -O -i "${output_prefix}_min.in" -o "${output_prefix}_energy.out" \
    -p "${output_prefix}.prmtop" -c "${output_prefix}.inpcrd" >> "$log_file" 2>&1 || {
    error_exit "sander failed on $pdb_filename"
}

# Extract energy and save to summary
energy=$(grep "FINAL" "${output_prefix}_energy.out" | tail -n 1)
echo "${pdb_base}: $energy" > "${output_prefix}_energy_summary.txt"

echo "----------------------------------------" >> "$log_file"
echo "Calculation completed at: $(date)" >> "$log_file"
echo "Results available in: $work_dir"