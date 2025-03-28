#!/usr/bin/env python3
"""
Generate all possible intermediate states between GA77 and GB77 sequences.
Each state is represented by a binary number where 0=GA77 residue and 1=GB77 residue.
The output resfiles are named according to the decimal representation of this binary number.
"""

import os
from itertools import combinations
from make_resfiles import sequence_to_resfile

def read_fasta(fasta_file):
    """Read sequences from a FASTA file."""
    sequences = {}
    current_seq = ""
    current_name = ""
    
    with open(fasta_file, 'r') as f:
        for line in f:
            line = line.strip()
            if line.startswith('>'):
                if current_seq:
                    sequences[current_name] = current_seq
                current_name = line[1:]
                current_seq = ""
            else:
                current_seq += line
    
    if current_seq:
        sequences[current_name] = current_seq
    
    return sequences

def find_differences(seq1, seq2):
    """Find positions where sequences differ."""
    differences = []
    for i, (aa1, aa2) in enumerate(zip(seq1, seq2)):
        if aa1 != aa2:
            differences.append(i)
    return differences

def generate_intermediate_sequence(ga77, gb77, binary_state):
    """Generate an intermediate sequence based on binary state."""
    result = list(ga77)
    for i, bit in enumerate(binary_state):
        if bit == '1':
            result[differences[i]] = gb77[differences[i]]
    return ''.join(result)

# Create output directory
os.makedirs('combinatoric_resfiles', exist_ok=True)

# Read sequences
sequences = read_fasta('data/sequences/ga77gb77.fasta')
ga77 = sequences['GA77']
gb77 = sequences['GB77']

# Find differences
differences = find_differences(ga77, gb77)
num_differences = len(differences)
print(f"Found {num_differences} differences between GA77 and GB77")

# Generate all possible states (2^13)
total_states = 2 ** num_differences
print(f"Generating {total_states} intermediate states...")

for i in range(total_states):
    # Convert decimal to binary, pad with zeros
    binary_state = format(i, f'0{num_differences}b')
    
    # Generate intermediate sequence
    intermediate_seq = generate_intermediate_sequence(ga77, gb77, binary_state)
    
    # Create resfile
    output_file = f'combinatoric_resfiles/{i}.txt'
    sequence_to_resfile(intermediate_seq, output_file, start_residue=1, chain='A')
    
    if (i + 1) % 100 == 0:
        print(f"Generated {i + 1} of {total_states} states")

print("Done generating all intermediate states!") 