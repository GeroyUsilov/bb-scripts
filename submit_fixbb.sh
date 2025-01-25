#!/bin/bash
#SBATCH --job-name=fixedbb_${1}_${2}
#SBATCH --output=fixedbb_${1}_${2}.out
#SBATCH --error=fixedbb_${1}_${2}.err
#SBATCH --account=pi-amurugan
#SBATCH --partition=broadwl
#SBATCH --time=00:04:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1


# Load required modules 
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