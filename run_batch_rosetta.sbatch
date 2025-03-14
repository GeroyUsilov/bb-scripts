#!/bin/bash
#SBATCH --job-name=fixedbb_array
#SBATCH --output=slurm-%A_%a.out
#SBATCH --error=slurm-%A_%a.err
#SBATCH --account=pi-amurugan
#SBATCH --partition=broadwl
#SBATCH --time=00:45:00
#SBATCH --array=1-8%8  # Run 8 tasks, max 8 at a time

echo "SLURM environment check:"
echo "SLURM_ARRAY_TASK_ID: $SLURM_ARRAY_TASK_ID"
echo "Current working directory: $(pwd)"

# Load required modules
module load rosetta

# Check input arguments
if [ $# -ne 2 ]; then
    echo "Usage: sbatch $0 <input_pdb_file> <resfiles_folder>"
    echo "Example: sbatch $0 structure.pdb resfiles_dir/"
    exit 1
fi

# Get absolute paths for input files
input_pdb=$(readlink -f "$1")
resfiles_dir=$(readlink -f "$2")

# Remove trailing slash from directory if present
resfiles_dir=${resfiles_dir%/}

# Get the base name of the PDB file and the resfiles directory
pdb_base=$(basename "$input_pdb" .pdb)
dir_base=$(basename "$resfiles_dir")

# Create master output directory
master_output_dir="${dir_base}_results"
mkdir -p "$master_output_dir"

# Create a symbolic link to the input PDB in the master output directory
# Use -f to force overwrite if the link already exists
ln -sf "$input_pdb" "$master_output_dir/$(basename $input_pdb)"

# Find all resfiles
find "$resfiles_dir" -type f -name "*.txt" > all_resfiles.txt
total_resfiles=$(wc -l < all_resfiles.txt)
echo "Found $total_resfiles resfiles to process"

# Make sure the task script is executable
chmod +x run_fixbb_task.sh

# Determine which resfile this task should process
# Using SLURM_ARRAY_TASK_ID to distribute work
RESFILES_PER_TASK=$(( (total_resfiles + SLURM_ARRAY_TASK_COUNT - 1) / SLURM_ARRAY_TASK_COUNT ))
START_INDEX=$(( (SLURM_ARRAY_TASK_ID - 1) * RESFILES_PER_TASK + 1 ))
END_INDEX=$(( START_INDEX + RESFILES_PER_TASK - 1 ))

echo "This task will process files from index $START_INDEX to $END_INDEX"

# Process the assigned portion of resfiles
for (( i = START_INDEX; i <= END_INDEX && i <= total_resfiles; i++ )); do
    resfile=$(sed -n "${i}p" all_resfiles.txt)
    echo "Processing resfile $i: $resfile"
    
    # Run fixbb directly with this resfile
    ./run_fixbb_task.sh "$input_pdb" "$resfile" "$master_output_dir"
    
    echo "Completed resfile $i"
done

echo "Task $SLURM_ARRAY_TASK_ID completed"