#!/bin/bash

# Input PDB file and resfile
input_pdb=$1
resfile=$2

if [ -z "$input_pdb" ] || [ -z "$resfile" ]; then
    echo "Usage: $0 <input_pdb_file> <resfile>"
    echo "Example: $0 structure.pdb my_resfile.txt"
    exit 1
fi

# Check if files exist
if [ ! -f "$input_pdb" ]; then
    echo "Error: Input PDB file $input_pdb not found"
    exit 1
fi

if [ ! -f "$resfile" ]; then
    echo "Error: Resfile $resfile not found"
    exit 1
fi

# Path to Rosetta database
rosetta_db="/software/rosetta-2017.08.59291-el7-x86_64/main/database"

# Path to Rosetta binaries
fixbb_exe="/software/rosetta-2017.08.59291-el7-x86_64/main/source/bin/fixbb.static.linuxgccrelease"
relax_exe="/software/rosetta-2017.08.59291-el7-x86_64/main/source/bin/relax.static.linuxgccrelease"

# Generate an output prefix based on the input PDB filename
output_prefix=$(basename "$input_pdb" .pdb)

# Step 1: Run fixbb to thread the sequence onto the backbone
echo "Running fixbb to thread sequence..."
$fixbb_exe \
    -s $input_pdb \
    -resfile $resfile \
    -packing:repack_only \
    -ex1 \
    -ex2 \
    -use_input_sc \
    -nstruct 10 \
    -linmem_ig 10 \
    -minimize_sidechains \
    -database $rosetta_db \
    -overwrite

# Step 2: Run relax with backbone constraints on the fixbb output
echo "Running relax with backbone constraints..."
for i in {1..10}; do
    input_model="${i}_${input_pdb}"
    if [ -f "$input_model" ]; then
        $relax_exe \
            -s $input_model \
            -relax:constrain_relax_to_start_coords \
            -relax:coord_constrain_sidechains \
            -relax:ramp_constraints false \
            -ex1 \
            -ex2 \
            -use_input_sc \
            -nstruct 1 \
            -database $rosetta_db \
            -overwrite
    fi
done

# Step 3: Extract and summarize scores
echo "Extracting scores..."
echo "Model\tTotal_Score\tRMSD" > relaxed_scores.tsv
for i in {1..10}; do
    relaxed_model="${i}_${output_prefix}_0001.pdb"
    if [ -f "$relaxed_model" ]; then
        score=$(grep "^score" $relaxed_model | awk '{print $2}')
        rmsd=$(grep "^REMARK" $relaxed_model | grep "rms" | awk '{print $NF}')
        echo "${i}\t${score}\t${rmsd}" >> relaxed_scores.tsv
    fi
done

echo "Analysis complete. Results in relaxed_scores.tsv"