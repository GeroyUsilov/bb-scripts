#!/bin/bash
#SBATCH --job-name=fiamber_energyxedbb
#SBATCH --output=slurm_logs/energy_calc_%j.log
#SBATCH --error=slurm_logs/energy_calc_%j.err
#SBATCH --account=pi-amurugan
#SBATCH --partition=broadwl
#SBATCH --time=00:45:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1


# The folder to process is passed as an argument
# The folder to process is passed as an argument
folder_path=$1

if [ -z "$folder_path" ]; then
    echo "Usage: sbatch script.sh <folder_path>"
    exit 1
fi

# Ensure the folder exists
if [ ! -d "$folder_path" ]; then
    echo "Error: Directory $folder_path does not exist"
    exit 1
fi

# Get folder name for outputs
folder_name=$(basename "$folder_path")

# Process each PDB file in the folder
cd "$folder_path" || exit 1

# Create a summary file with timestamp
date > "${folder_name}_energy_summary.txt"

for pdb in *.pdb; do
    if [ -f "$pdb" ]; then
        /path/to/calc_energy.sh "$pdb" 2>&1 | tee -a "${folder_name}_energy_summary.txt"
    fi
done