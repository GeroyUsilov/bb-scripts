#!/usr/bin/env python3

def extract_model1_from_nmr(input_pdb, output_pdb):
    """
    Extract model 1 from an NMR ensemble PDB file and prepare it for Rosetta.
    
    Args:
        input_pdb (str): Path to input PDB file
        output_pdb (str): Path to output PDB file
    """
    model1_lines = []
    in_model1 = False
    
    with open(input_pdb, 'r') as f:
        for line in f:
            # Keep header information
            if line.startswith(('HEADER', 'TITLE', 'COMPND', 'SOURCE', 'KEYWDS', 'EXPDTA', 'AUTHOR', 'REMARK')):
                model1_lines.append(line)
            
            # Start collecting Model 1
            if line.startswith('MODEL        1'):
                in_model1 = True
                continue
                
            # Stop when we hit Model 2
            if line.startswith('MODEL        2'):
                break
                
            # Collect ATOM records for Model 1
            if in_model1 and line.startswith(('ATOM', 'TER', 'END')):
                model1_lines.append(line)
    
    # Write cleaned file
    with open(output_pdb, 'w') as f:
        for line in model1_lines:
            f.write(line)

if __name__ == "__main__":
    import sys
    if len(sys.argv) != 3:
        print("Usage: python extract_model1.py input.pdb output.pdb")
        sys.exit(1)
    
    extract_model1_from_nmr(sys.argv[1], sys.argv[2])