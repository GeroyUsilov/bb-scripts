#!/bin/bash

# Output CSV file
output_csv="relax_results.csv"
echo "x,y,z,result" > $output_csv

# Define ranges to loop over
y_range=("1pga" "2fs1" "2jws" "2jwu" "2kdl" "2kdm")
z_range=("0001" "0002" "0003" "0004" "0005" "0006" "0007" "0008" "0009" "0010")

for ((x=0; x<=8191; x++)); do
  for y in "${y_range[@]}"; do
    for z in "${z_range[@]}"; do
      # Execute command and capture result
      result=$(tar -xzOf combinatoric_results/${x}_output/${y}_relax.tar.gz project/amurugan/cjrusso/bb-scripts/combinatoric_results/${x}_output/${y}_relax/2fs1_${z}_0001.pdb | grep "^pose" | awk '{print $NF}' 2>/dev/null)
      
      # Only write to CSV if command succeeded and result is not empty
      if [ $? -eq 0 ] && [ ! -z "$result" ]; then
        echo "$x,$y,$z,$result" >> $output_csv
      fi
    done
  done
done

echo "Processing complete. Results saved to $output_csv"