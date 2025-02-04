#!/bin/bash

# Exit on error
set -e

# Function to print error messages
error_exit() {
    echo "ERROR: $1" >&2
    exit 1
}
# Check input first
# Input PDB file
pdb_file=$1
if [ -z "$pdb_file" ]; then
    error_exit "Usage: $0 <pdb_file>"
fi
if [ ! -f "$pdb_file" ]; then
    error_exit "Input file $pdb_file does not exist"
fi

# Setup environment
export PATH="/software/amber-20-el7-x86_64+intelmpi-2017.up4+intel-17.0/bin:$PATH"
source /software/amber-20-el7-x86_64+intelmpi-2017.up4+intel-17.0/miniconda/bin/activate


# Then define and run dependencies check
# Function to check if commands exist
check_dependencies() {
    local cmds=("pdb4amber" "tleap" "sander")
    for cmd in "${cmds[@]}"; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            error_exit "$cmd is required but not found in PATH"
        fi
    done
}

# Check dependencies
check_dependencies



# Create working directory
timestamp=$(date +%Y%m%d_%H%M%S)
work_dir="amber_calc_${timestamp}"
mkdir -p "$work_dir"
cp "$pdb_file" "$work_dir/"
cd "$work_dir"

# Base name for output files
base_name=$(basename "$pdb_file" .pdb)

echo "Processing PDB file..."

# Pre-process PDB with pdb4amber
echo "Running pdb4amber..."
pdb4amber -i "$pdb_file" -o "${base_name}_processed.pdb" 2>&1 || error_exit "pdb4amber failed"

# Create tleap input file
cat > leap.in << EOF
# Load force fields
source leaprc.protein.ff14SB
source leaprc.water.tip3p

# Load and process molecule
mol = loadpdb ${base_name}_processed.pdb

# Check for missing atoms
check mol

# Save parameters
saveamberparm mol ${base_name}.prmtop ${base_name}.inpcrd

# Save processed structure
savepdb mol ${base_name}_final.pdb

quit
EOF

# Run tleap
echo "Running tleap..."
tleap -f leap.in > leap.log 2>&1 || error_exit "tleap failed"

# Check for common errors in leap.log
if grep -q "ERROR" leap.log; then
    echo "WARNING: Found errors in leap.log:"
    grep "ERROR" leap.log
    error_exit "LEaP encountered errors"
fi

# Create minimization input file
cat > min.in << EOF
Single point energy calculation
 &cntrl
   imin=5,           ! Single point energy calculation
   ntb=0,            ! No periodic boundary
   maxcyc=0,         ! No minimization steps
   cut=999.0,        ! Effectively infinite cutoff
   ntpr=1,           ! Print every step
   ntwx=0,           ! Don't write coordinates
   ntwe=0,           ! Don't write energies
   ntwr=0,           ! Don't write restrt file
 /
EOF

# Run sander
echo "Running energy calculation..."
sander -O -i min.in -o "${base_name}_energy.out" -p "${base_name}.prmtop" -c "${base_name}.inpcrd" || error_exit "sander failed"

# Extract and format energy results
echo -e "\nEnergy Results for ${pdb_file}:"
echo "----------------------------------------"
grep "FINAL" "${base_name}_energy.out" || error_exit "No energy results found"
echo "----------------------------------------"

# Create results directory and move important files
mkdir -p results
mv "${base_name}_energy.out" results/
mv "${base_name}.prmtop" results/
mv "${base_name}.inpcrd" results/
mv "${base_name}_final.pdb" results/
mv leap.log results/

# Clean up intermediate files
rm -f min.in leap.in "${base_name}_processed.pdb"

echo -e "\nCalculation completed successfully!"
echo "Results are saved in: $work_dir/results/"