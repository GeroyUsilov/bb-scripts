#!/bin/sh

#SBATCH --time=24:00:00
#SBATCH --array=0-63
#SBATCH --account=pi-amurugan
#SBATCH --partition=broadwl
#SBATCH --mem-per-cpu=4G
#SBATCH --output=slurm-%A_%a.out
#SBATCH --error=slurm-%A_%a.err



# Output CSV file
output_csv="relax_results.csv"


# Define ranges to loop over
y_range=("1pga" "2fs1" "2jws" "2jwu" "2kdl" "2kdm")
z_range=("0001" "0002" "0003" "0004" "0005" "0006" "0007" "0008" "0009" "0010")

for ((x=${SLURM_ARRAY_TASK_ID}*128; x<=${SLURM_ARRAY_TASK_ID}*128 + 127; x++)); do
  for y in "${y_range[@]}"; do
    for z in "${z_range[@]}"; do
      # Execute command and capture result
      result=$(tar -xzOf combinatoric_results/${x}_output/${y}_relax.tar.gz project/amurugan/cjrusso/bb-scripts/combinatoric_results/${x}_output/${y}_relax/${y}_${z}_0001.pdb | grep "^pose" | awk '{print $NF}' 2>/dev/null)
      
      # Only write to CSV if command succeeded and result is not empty
      if [ $? -eq 0 ] && [ ! -z "$result" ]; then
        echo "$x,$y,$z,$result" >> $output_csv
      fi
    done
  done
done

echo "Processing complete. Results saved to $output_csv"