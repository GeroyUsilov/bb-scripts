#!/bin/bash
#SBATCH --job-name=fixbb
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=4G
#SBATCH --time=2:00:00
#SBATCH --output=fixbb_%j.out
#SBATCH --error=fixbb_%j.err

# Load required modules (modify as needed for your HPC)
module load rosetta

# Input PDB file and resfile
input_pdb=$1
resfile=$2

if [ -z "$input_pdb" ] || [ -z "$resfile" ]; then
    echo "Usage: sbatch $0 <input_pdb_file> <resfile>"
    echo "Example: sbatch $0 structure.pdb my_resfile.txt"
    exit 1
fi

# Run the fixbb script
./run_fixbb.sh "$input_pdb" "$resfile"