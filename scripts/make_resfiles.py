#!/usr/bin/env python3
"""
This script was automatically generated from make_resfiles.ipynb.
"""

def sequence_to_resfile(sequence, output_file='resfile', start_residue=1, chain='A'):
    """
    Convert an amino acid sequence to a Rosetta resfile and save it.
    
    Args:
        sequence (str): Amino acid sequence in one-letter code (e.g., 'MKLLPVRG')
        output_file (str): Name of output resfile (default: 'resfile')
        start_residue (int): Starting residue number (default: 1)
        chain (str): Chain ID (default: 'A')
    """
    # Header for resfile
    resfile_content = ["NATRO  # Keep all other residues fixed", "start"]
    
    # Convert each amino acid in sequence
    for i, aa in enumerate(sequence.upper(), start=start_residue):
        resfile_content.append(f"{i} {chain} PIKAA {aa}")
    
    # Write to file
    with open(output_file, 'w') as f:
        f.write('\n'.join(resfile_content))
    
    print(f"Created resfile: {output_file}")
    print("Content:")
    print('\n'.join(resfile_content))

import random

# List of standard amino acids in one-letter code
amino_acids = "ACDEFGHIKLMNPQRSTVWY"

def generate_random_sequence(length):
    """Generate a random amino acid sequence of specified length."""
    return ''.join(random.choice(amino_acids) for _ in range(length))

#GA95
sequence = "TTYKLILNLKQAKEEAIKELVDAGTAEKYIKLIANAKTVEGVWTLKDEIKTFTVTE"
sequence_to_resfile(sequence, output_file='resfiles/GA95.txt', start_residue=1, chain='A')

#GB95
sequence = "TTYKLILNLKQAKEEAIKEAVDAGTAEKYFKLIANAKTVEGVWTYKDEIKTFTVTE"
sequence_to_resfile(sequence, output_file='resfiles/GB95.txt', start_residue=1, chain='A')

#GA77
sequence = "TTYKLILNLKQAKEEAIKELVDAGIAEKYIKLIANAKTVEGVWTLKDEILKATVTE"
sequence_to_resfile(sequence, output_file='resfiles/GA77.txt', start_residue=1, chain='A')

#GB77
sequence = "TTYKLILNGKQLKEEAITEAVDAATAEKYFKLYANAKTVEGVWTYKDETKTFTVTE"
sequence_to_resfile(sequence, output_file='resfiles/GB77.txt', start_residue=1, chain='A')

#GA88
sequence = "TTYKLILNLKQAKEEAIKELVDAGIAEKYIKLIANAKTVEGVWTLKDEILTFTVTE"
sequence_to_resfile(sequence, output_file='resfiles/GA88.txt', start_residue=1, chain='A')

#GA91
sequence = "TTYKLILNLKQAKEEAIKELVDAGTAEKYIKLIANAKTVEGVWTLKDEILTFTVTE"
sequence_to_resfile(sequence, output_file='resfiles/GA91.txt', start_residue=1, chain='A')

#GA98
sequence = "TTYKLILNLKQAKEEAIKELVDAGTAEKYFKLIANAKTVEGVWTLKDEIKTFTVTE"
sequence_to_resfile(sequence, output_file='resfiles/GA98.txt', start_residue=1, chain='A')

#GB98
sequence = "TTYKLILNLKQAKEEAIKELVDAGTAEKYFKLIANAKTVEGVWTYKDEIKTFTVTE"
sequence_to_resfile(sequence, output_file='resfiles/GB98.txt', start_residue=1, chain='A')

#GB91
sequence = "TTYKLILNLKQAKEEAIKEAVDAGTAEKYFKLIANAKTVEGVWTYKDEIKTFTVTE"
sequence_to_resfile(sequence, output_file='resfiles/GB91.txt', start_residue=1, chain='A')

#GB88
sequence = "TTYKLILNLKQAKEEAITEAVDAGTAEKYFKLYANAKTVEGVWTYKDEIKTFTVTE"
sequence_to_resfile(sequence, output_file='resfiles/GB88.txt', start_residue=1, chain='A')

sequence = "TTYKLILNLKQAKEEAIKELVDAGTAEKYFKLIANAKTVEGVWTYKDEIKTFTVTE"
sequence_to_resfile(sequence, output_file='resfiles/GB98.txt', start_residue=1, chain='A')

#GBWT
sequence = "MTYKLILNGKTLKGETTTEAVDAATAEKVFKQYANDNGVDGEWTYDDATKTFTVTE"
sequence_to_resfile(sequence, output_file='resfiles/GBWT.txt', start_residue=1, chain='A')

#GAWT
sequence = "MEAVDANSLAQAKEAAIKELKQYGIGDYYIKLINNAKTVEGVESLKNEILKALPTE"
sequence_to_resfile(sequence, output_file='resfiles/GAWT.txt', start_residue=1, chain='A')

sequence_length = len(sequence)
n = 30

for i in range(n):
        # Generate random sequence of the same length as your example
        random_sequence = generate_random_sequence(sequence_length)
        
        # Process the sequence and save to a numbered output file
        output_file = f'resfiles/random_{i}.txt'
        sequence_to_resfile(random_sequence, output_file, start_residue=1, chain='A')
        
        print(f"Generated file {output_file} for sequence: {random_sequence}")

