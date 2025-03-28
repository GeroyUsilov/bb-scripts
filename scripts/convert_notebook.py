#!/usr/bin/env python3
"""
Convert a Jupyter notebook to a Python script.
This is useful for running notebook logic as standalone scripts.
"""

import sys
import json
import os

def convert_notebook_to_script(notebook_file, output_file=None):
    """
    Convert a Jupyter notebook to a Python script.
    
    Args:
        notebook_file (str): Path to the notebook file
        output_file (str, optional): Path to the output script file.
            If None, use the same basename with .py extension
    """
    if output_file is None:
        base_name = os.path.splitext(notebook_file)[0]
        output_file = f"{base_name}.py"
    
    with open(notebook_file, 'r') as f:
        notebook = json.load(f)
    
    with open(output_file, 'w') as f:
        f.write('#!/usr/bin/env python3\n')
        f.write('"""\n')
        f.write(f'This script was automatically generated from {os.path.basename(notebook_file)}.\n')
        f.write('"""\n\n')
        
        for cell in notebook['cells']:
            if cell['cell_type'] == 'code':
                # Get the source code
                source = ''.join(cell['source'])
                
                # Skip empty cells
                if not source.strip():
                    continue
                
                # Write the code to the output file
                f.write(source)
                
                # Add a newline if the cell doesn't end with one
                if not source.endswith('\n'):
                    f.write('\n')
                f.write('\n')
    
    # Make the script executable
    os.chmod(output_file, 0o755)
    
    print(f"Converted {notebook_file} to {output_file}")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python convert_notebook.py notebook.ipynb [output.py]")
        sys.exit(1)
    
    notebook_file = sys.argv[1]
    output_file = sys.argv[2] if len(sys.argv) > 2 else None
    
    convert_notebook_to_script(notebook_file, output_file) 