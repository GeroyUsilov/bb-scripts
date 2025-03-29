#!/bin/sh

#SBATCH --time=24:00:00
#SBATCH --array=0-100
#SBATCH --account=pi-amurugan
#SBATCH --partition=broadwl
#SBATCH --mem-per-cpu=4G
#SBATCH --output=combinatoric_results/%a_output/slurm-%A_%a.out
#SBATCH --error=combinatoric_results/%a_output/slurm-%A_%a.err

# Get the resfile for this array index
resfile="combinatoric_resfiles/${SLURM_ARRAY_TASK_ID}.txt"

# Check if resfile exists
if [ ! -f "$resfile" ]; then
    echo "Error: Resfile $resfile not found"
    exit 1
fi

# Run the task
./scripts/runtask_combinatoric.sh "$resfile"