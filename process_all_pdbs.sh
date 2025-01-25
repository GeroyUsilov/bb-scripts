#!/bin/bash
#SBATCH --job-name=amber_energy
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=4G
#SBATCH --time=2:00:00
#SBATCH --output=amber_%j.out
#SBATCH --error=amber_%j.err

# Load required modules (modify as needed for your HPC)
module load amber

# Directory containing PDB files
input_dir=$1

if [ -z "$input_dir" ]; then
    echo "Usage: sbatch $0 <directory_with_pdbs>"
    exit 1
fi

# Create output summary file
echo "PDB_File Energy" > energy_summary.txt

# Process each PDB file
for pdb in ${input_dir}/*.pdb; do
    ./calc_amber_energy.sh "$pdb"
    
    # Extract energy and append to summary
    energy=$(grep "FINAL" *_energy.out | awk '{print $3}')
    echo "$(basename $pdb) $energy" >> energy_summary.txt
done

# Sort results by energy
echo -e "\nSorted energies (lowest to highest):"
sort -k2 -n energy_summary.txt