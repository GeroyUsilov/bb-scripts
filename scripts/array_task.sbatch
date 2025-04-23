#!/bin/sh

#SBATCH --time=24:00:00
#SBATCH --array=0-100
#SBATCH --account=pi-amurugan
#SBATCH --partition=broadwl
#SBATCH --mem-per-cpu=4G
#SBATCH --output=combinatoric_results/%a_output/slurm-%A_%a.out
#SBATCH --error=combinatoric_results/%a_output/slurm-%A_%a.err

# Get script directory for absolute paths
SCRIPT_DIR="${SLURM_SUBMIT_DIR}"

# Get the resfile with absolute path
resfile="$SCRIPT_DIR/combinatoric_resfiles/${SLURM_ARRAY_TASK_ID}.txt"

# Check if resfile exists
if [ ! -f "$resfile" ]; then
    echo "Error: Resfile $resfile not found"
    exit 1
fi

# Run the task with absolute paths
$SCRIPT_DIR/scripts/runtask_combinatoric_1pdb.sh "$resfile" "2fs1.pdb"