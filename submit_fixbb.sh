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

# Get absolute paths for input files
input_pdb=$(readlink -f "$1")
resfile=$(readlink -f "$2")

# Remove file extensions and create job name
pdb_base=$(basename "$input_pdb" .pdb)
resfile_base=$(basename "$resfile" .txt)
job_name="fixedbb_${pdb_base}_${resfile_base}"
scontrol update job $SLURM_JOB_ID name=$job_name

# Create output directory
output_dir="${job_name}_output"
mkdir -p "$output_dir"

if [ -z "$input_pdb" ] || [ -z "$resfile" ]; then
    echo "Usage: sbatch $0 <input_pdb_file> <resfile>"
    echo "Example: sbatch $0 structure.pdb my_resfile.txt"
    exit 1
fi

# Create symbolic links to input files in the output directory
ln -s "$input_pdb" "$output_dir/$(basename $input_pdb)"
ln -s "$resfile" "$output_dir/$(basename $resfile)"

# Change to output directory
cd "$output_dir"

# Run the fixbb script with the symlinked files
../run_fixbb.sh "$(basename $input_pdb)" "$(basename $resfile)"

# Move output files to the output directory
mv ../slurm-$SLURM_JOB_ID.out ./${job_name}.out
mv ../slurm-$SLURM_JOB_ID.err ./${job_name}.err