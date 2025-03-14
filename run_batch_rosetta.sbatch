#!/bin/sh
#SBATCH --job-name=fixedbb_parallel
#SBATCH --output=slurm-%j.out
#SBATCH --error=slurm-%j.err
#SBATCH --account=pi-amurugan
#SBATCH --partition=broadwl
#SBATCH --time=00:45:00
#SBATCH --ntasks=8

# Load required modules
module load rosetta
module load parallel

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
ln -s "$input_pdb" "$master_output_dir/$(basename $input_pdb)"

# For a large number of tasks, increase the user process limit
ulimit -u 10000

# Check if run_fixbb_task.sh exists
if [ ! -f "run_fixbb_task.sh" ]; then
    echo "Error: run_fixbb_task.sh not found. Make sure it exists and is executable."
    exit 1
fi

# Make sure the task script is executable
chmod +x run_fixbb_task.sh

# Find all resfiles
find "$resfiles_dir" -type f -name "*.txt" > all_resfiles.txt

# the --exclusive to srun make srun use distinct CPUs for each job step
# -N1 -n1 allocates a single core to each task
srun="srun --exclusive -N1 -n1"
echo "srun variable set"
# --delay .2 prevents overloading the controlling node
# -j is the number of tasks parallel runs (set to SLURM_NTASKS)
# --joblog makes parallel create a log of tasks it has already run
# --resume lets parallel use the joblog to resume from where it left off
parallel="parallel --delay .2 -j $SLURM_NTASKS --joblog runtask.log --resume"

# Run parallel for all resfiles, passing the PDB file and output directory
$parallel "$srun ./run_fixbb_task.sh $input_pdb {} $master_output_dir" :::: all_resfiles.txt


# Keep all_resfiles.txt and runtask.log for reference and possible resumption
