#!/bin/bash

# Make run_fixbb.sh executable
chmod u+x run_fixbb.sh

# Check if directories exist
if [ ! -d "pdb_files" ]; then
    echo "Error: pdb_files directory not found"
    exit 1
fi

if [ ! -d "resfiles" ]; then
    echo "Error: resfiles directory not found"
    exit 1
fi

# Loop through each combination of files and submit jobs
for file1 in pdb_files/*; do
    # Check if file1 exists and is readable
    if [ ! -r "$file1" ]; then
        echo "Warning: Cannot read $file1, skipping..."
        continue
    fi
    
    for file2 in resfiles/*; do
        # Check if file2 exists and is readable
        if [ ! -r "$file2" ]; then
            echo "Warning: Cannot read $file2, skipping..."
            continue
        fi
        
        echo "Submitting job for $file1 and $file2..."
        sbatch ./submit_fixbb.sh "$file1" "$file2"
    done
done

echo "All jobs submitted!"