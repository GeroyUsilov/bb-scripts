#!/bin/sh

#SBATCH --time=24:00:00
#SBATCH --array=$1-$2
#SBATCH --account=pi-amurugan
#SBATCH --partition=broadwl
#SBATCH --mem-per-cpu=4G
#SBATCH --output=combinatoric_results/%a_output/slurm-%A_%a.out
#SBATCH --error=combinatoric_results/%a_output/slurm-%A_%a.err

# Check if start and end indices are provided
if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: $0 <start_index> <end_index>"
    echo "Example: $0 0 100"
    exit 1
fi

# Validate indices
if [ $1 -lt 0 ] || [ $2 -gt 8191 ] || [ $1 -gt $2 ]; then
    echo "Error: Invalid index range. Must be between 0 and 8191, with start <= end"
    exit 1
fi

# Make runtask script executable
chmod u+x $(dirname "$0")/runtask_combinatoric.sh

# Get the resfile for this array index
resfile="combinatoric_resfiles/${SLURM_ARRAY_TASK_ID}.txt"

# Check if resfile exists
if [ ! -f "$resfile" ]; then
    echo "Error: Resfile $resfile not found"
    exit 1
fi

# Run the task
./scripts/runtask_combinatoric.sh "$resfile"