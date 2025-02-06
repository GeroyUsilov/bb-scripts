#!/bin/bash
#SBATCH --account=pi-amurugan
#SBATCH --partition=broadwl
#SBATCH --time=00:45:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1

# Load modules
module load amber
module load python_ucs4/2.7.13+gcc-6.2


# Setup Amber environment
source /software/amber-20-el7-x86_64+intelmpi-2017.up4+intel-17.0/amber.sh

# Check arguments
if [ $# -ne 2 ]; then
    echo "Usage: $0 <directory> <pdb_file>"
    exit 1
fi

directory=$1
pdb_file=$2

./calculate_single.sh "$directory" "$pdb_file"