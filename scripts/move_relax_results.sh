#!/bin/bash

# Path to the original parent directory containing x_output directories
SRC_DIR="combinatoric_results"  # Modify this to your actual source directory

# Create the main output directory
mkdir -p relax_results

# Process each subdirectory
for dir in "$SRC_DIR"/*_output/; do
  if [[ $dir =~ ${SRC_DIR}/([0-9]+)_output/ ]]; then
    x=${BASH_REMATCH[1]}
    
    # Create corresponding directory in the output
    mkdir -p "relax_results/${x}_output"
    
    # Process each tar.gz file in the directory
    for tarfile in "$dir"*_relax.tar.gz; do
      if [[ $tarfile =~ ${dir}([A-Za-z0-9]{4})_relax\.tar\.gz ]]; then
        yyyy=${BASH_REMATCH[1]}
        
        # Create target directory
        mkdir -p "relax_results/${x}_output/${yyyy}_relax"
        
        # Extract only the needed file
        tar -xzf "$tarfile" -C "relax_results/${x}_output/${yyyy}_relax" --strip-components=1 "*/relaxed_scores.tsv"
      fi
    done
  fi
done

echo "Extraction complete. Files are in relax_results/"