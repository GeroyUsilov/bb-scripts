#!/bin/bash
#SBATCH --job-name=fixedbb
#SBATCH --output=slurm-%j.out
#SBATCH --error=slurm-%j.err
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

# Update job name with parameters
job_name="fixedbb_${input_pdb}_${resfile}"
scontrol update job $SLURM_JOB_ID name=$job_name

# Run the fixbb script
./run_fixbb.sh "$input_pdb" "$resfile"

# Rename output files after job completion
mv slurm-$SLURM_JOB_ID.out ${job_name}.out
mv slurm-$SLURM_JOB_ID.err ${job_name}.err