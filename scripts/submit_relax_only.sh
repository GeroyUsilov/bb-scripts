#!/bin/bash
#SBATCH --job-name=relax_models
#SBATCH --output=slurm-%j.out
#SBATCH --error=slurm-%j.err
#SBATCH --account=pi-amurugan
#SBATCH --partition=broadwl
#SBATCH --time=00:45:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1

# Load required modules
module load rosetta

# Get absolute paths for input and output directories
input_dir=$(readlink -f "$1")

# Extract the base name of the input directory (final subdirectory)
input_subdir_name=$(basename "$input_dir")

output_dir="$SCRIPT_DIR/results/relax_only/$input_subdir_name"  # Default output dir if not specified

# Create job name based on input directory
dir_base=$(basename "$input_dir")
job_name="relax_${dir_base}"
scontrol update job $SLURM_JOB_ID name=$job_name

# Check if input directory is provided
if [ -z "$input_dir" ]; then
    echo "Usage: sbatch $0 <input_directory> [output_directory]"
    echo "Example: sbatch $0 fixbb_models relaxed_output"
    exit 1
fi

# Create output directory
mkdir -p "$output_dir"

# Run the relax script
SCRIPT_DIR="${SLURM_SUBMIT_DIR}"/scripts
$SCRIPT_DIR/run_relax_only.sh "$input_dir" "$output_dir"


# Move SLURM log files to the output directory
mv slurm-$SLURM_JOB_ID.out "$output_dir/${job_name}.out"
mv slurm-$SLURM_JOB_ID.err "$output_dir/${job_name}.err"

echo "Relaxation job complete. Results in $output_dir"