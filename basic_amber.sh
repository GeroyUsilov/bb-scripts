#!/bin/bash
#SBATCH --job-name=amberenergy
#SBATCH --output=energy_calc_%j.log
#SBATCH --error=energy_calc_%j.err
#SBATCH --account=pi-amurugan
#SBATCH --partition=broadwl
#SBATCH --time=00:45:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1


# The folder to process is passed as an argument
# The folder to process is passed as an argument
module load amber
module load python/2.7
pdb_file=$1


# Create a summary file with timestamp
date > "energy_summary.txt"

./calc_amber_energy.sh "$pdb_file" 2>&1 | tee -a "energy_summary.txt"
