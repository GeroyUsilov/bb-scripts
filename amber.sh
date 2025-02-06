#!/bin/bash
#SBATCH --account=pi-amurugan
#SBATCH --partition=broadwl
#SBATCH --time=00:45:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1

# Load required modules
module load amber
module load python_ucs4/2.7.13+gcc-6.2

# The folder to process is passed as an argument
folder=$1

if [ -z "$folder" ]; then
    echo "ERROR: Please provide folder path"
    exit 1
fi

./calc_amber_energy.sh "$folder"