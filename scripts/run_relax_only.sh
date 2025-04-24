#!/bin/bash

# Input parameters: folder with models and optional output folder
input_folder=$1
output_folder="${input_folder}_relax"  # Append _relax to input folder name

if [ -z "$input_folder" ]; then
    echo "Usage: $0 <input_folder>"
    echo "Example: $0 fixbb_models"
    exit 1
fi

# Check if input folder exists
if [ ! -d "$input_folder" ]; then
    echo "Error: Input folder $input_folder not found"
    exit 1
fi

# Create output folder if it doesn't exist
mkdir -p "$output_folder"

# Path to Rosetta database and binaries
rosetta_db="/software/rosetta-2017.08.59291-el7-x86_64/main/database"
relax_exe="/software/rosetta-2017.08.59291-el7-x86_64/main/source/bin/relax.static.linuxgccrelease"

# Prepare score output file
echo -e "Model\tTotal_Score\tRMSD" > "$output_folder/relaxed_scores.tsv"

# Process each PDB file in the input folder
echo "Running relax on models in $input_folder..."
for model in "$input_folder"/*.pdb; do
    if [ -f "$model" ]; then
        model_name=$(basename "$model")
        echo "Relaxing $model_name..."
        
        # Run relax with backbone constraints
        $relax_exe \
            -s "$model" \
            -relax:constrain_relax_to_start_coords \
            -relax:coord_constrain_sidechains \
            -relax:ramp_constraints false \
            -ex1 -ex2 \
            -use_input_sc \
            -nstruct 1 \
            -out:path:all "$output_folder" \
            -database "$rosetta_db" \
            -overwrite
        
        # Find the relaxed model in the output folder
        relaxed_model="$output_folder/$(basename "$model" .pdb)_0001.pdb"
        
        if [ -f "$relaxed_model" ]; then
            # Extract model ID, score, and RMSD
            model_id=$(basename "$model" .pdb)
            score=$(grep "^pose" output_model.pdb | awk '{print $(NF-1)}')
            rmsd=$(grep "^REMARK" "$relaxed_model" | grep "rms" | awk '{print $NF}')
            
            # Add to scores file
            echo -e "${model_id}\t${score:-N/A}\t${rmsd:-N/A}" >> "$output_folder/relaxed_scores.tsv"
        else
            echo "Warning: Expected relaxed model $relaxed_model not found"
        fi
    fi
done

echo "Analysis complete. Results in $output_folder/relaxed_scores.tsv"

# Compress both folders using tar and gzip
echo "Compressing input and output folders..."
tar -czf "${input_folder}.tar.gz" "$input_folder"
tar -czf "${output_folder}.tar.gz" "$output_folder"

# Remove original folders after successful compression
if [ $? -eq 0 ]; then
    rm -rf "$input_folder" "$output_folder"
    echo "Compressed folders created: ${input_folder}.tar.gz and ${output_folder}.tar.gz"
    echo "Original folders removed."
else
    echo "Error during compression. Original folders retained."
fi