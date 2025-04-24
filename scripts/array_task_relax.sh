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

# Define paths
base_dir="$SCRIPT_DIR/combinatoric_results"
tarfile="${base_dir}/${SLURM_ARRAY_TASK_ID}_output.tar.gz"
extract_dir="${base_dir}/${SLURM_ARRAY_TASK_ID}_output"

# Check if tarfile exists
if [ ! -f "$tarfile" ]; then
    echo "Error: Tarfile $tarfile not found"
    exit 1
fi

# Extract the tar.gz file to its original directory name
tar -xzf "$tarfile" -C "$base_dir"

# Remove the tar.gz file after successful extraction
rm "$tarfile"

# Loop through all directories in the extracted contents
for dir in "$extract_dir"/*/ ; do
    if [ -d "$dir" ]; then
        echo "Processing directory: $dir"
        # Run the relax script on each directory
        "$SCRIPT_DIR/scripts/run_relax_only.sh" "$dir"
    fi
done