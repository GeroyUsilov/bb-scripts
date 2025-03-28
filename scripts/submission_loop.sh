#!/bin/bash

# Make run_fixbb.sh executable
chmod u+x $(dirname "$0")/run_fixbb.sh

# Check if directories exist
if [ ! -d "data/pdb_files" ]; then
    echo "Error: data/pdb_files directory not found"
    exit 1
fi

if [ ! -d "data/resfiles" ]; then
    echo "Error: data/resfiles directory not found"
    exit 1
fi

# Loop through each combination of files and submit jobs
for file1 in data/pdb_files/*; do
    # Check if file1 exists and is readable
    if [ ! -r "$file1" ]; then
        echo "Warning: Cannot read $file1, skipping..."
        continue
    fi
    
    for file2 in data/resfiles/*; do
        # Check if file2 exists and is readable
        if [ ! -r "$file2" ]; then
            echo "Warning: Cannot read $file2, skipping..."
            continue
        fi
        
        echo "Submitting job for $file1 and $file2..."
        sbatch $(dirname "$0")/submit_fixbb.sh "$file1" "$file2"
    done
done

echo "All jobs submitted!"