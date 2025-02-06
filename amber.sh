#!/bin/bash
set -e

# Function to print error messages
error_exit() {
    echo "ERROR: $1" >&2
    exit 1
}

# Setup Amber environment
source /software/amber-20-el7-x86_64+intelmpi-2017.up4+intel-17.0/amber.sh

# Check input
if [ $# -ne 1 ]; then
    error_exit "Usage: $0 <folder_path>"
fi

folder_path="$1"
if [ ! -d "$folder_path" ]; then
    error_exit "Folder $folder_path does not exist"
fi

# Create results directory in the input folder
results_dir="${folder_path}/amber_results"
mkdir -p "$results_dir"

# Log file setup
log_file="${results_dir}/calculation.log"
echo "AMBER Energy Calculation - $(date)" > "$log_file"
echo "Processing folder: $folder_path" >> "$log_file"
echo "----------------------------------------" >> "$log_file"

# Process each PDB file
find "$folder_path" -type f -name "*.pdb" | while read -r pdb_file; do
    pdb_name=$(basename "$pdb_file" .pdb)
    echo "Processing: $pdb_name" | tee -a "$log_file"
    
    # Create and work in temporary directory
    work_dir=$(mktemp -d)
    cd "$work_dir"
    
    # Run pdb4amber
    pdb4amber -i "$pdb_file" -o "processed.pdb" >> "$log_file" 2>&1 || {
        echo "Failed: pdb4amber on $pdb_name" | tee -a "$log_file"
        cd - > /dev/null
        rm -rf "$work_dir"
        continue
    }

    # Create and run tleap
    cat > leap.in << EOF
source leaprc.protein.ff14SB
source leaprc.water.tip3p
mol = loadpdb processed.pdb
check mol
saveamberparm mol system.prmtop system.inpcrd
savepdb mol final.pdb
quit
EOF

    tleap -f leap.in >> "$log_file" 2>&1 || {
        echo "Failed: tleap on $pdb_name" | tee -a "$log_file"
        cd - > /dev/null
        rm -rf "$work_dir"
        continue
    }

    # Run energy calculation
    cat > min.in << EOF
Single point energy calculation
 &cntrl
   imin=5, ntb=0, maxcyc=0, cut=999.0,
   ntpr=1, ntwx=0, ntwe=0, ntwr=0
 /
EOF

    sander -O -i min.in -o "energy.out" -p system.prmtop -c system.inpcrd >> "$log_file" 2>&1 || {
        echo "Failed: sander on $pdb_name" | tee -a "$log_file"
        cd - > /dev/null
        rm -rf "$work_dir"
        continue
    }

    # Create structure's results directory and move files
    struct_dir="${results_dir}/${pdb_name}"
    mkdir -p "$struct_dir"
    
    # Move and rename final files
    mv energy.out "${struct_dir}/${pdb_name}_energy.out"
    mv system.prmtop "${struct_dir}/${pdb_name}.prmtop"
    mv system.inpcrd "${struct_dir}/${pdb_name}.inpcrd"
    mv final.pdb "${struct_dir}/${pdb_name}_final.pdb"
    mv leap.in "${struct_dir}/leap.in"
    
    # Extract energy and add to summary
    energy=$(grep "FINAL" "energy.out" | tail -n 1)
    echo "${pdb_name}: $energy" >> "${results_dir}/energy_summary.txt"
    
    # Clean up
    cd - > /dev/null
    rm -rf "$work_dir"
    
    echo "Completed: $pdb_name" | tee -a "$log_file"
done

echo "----------------------------------------" >> "$log_file"
echo "Processing completed at: $(date)" >> "$log_file"