#!/usr/bin/env python3
"""
collect_energy.py

Collects energy values from all .txt files in the current directory and subdirectories.
Each text file is expected to contain a single energy value.

Usage:
    ./collect_energy.py             # Process current directory
    ./collect_energy.py /some/path  # Process specific directory
"""

import os
import sys
import pandas as pd
from pathlib import Path

def collect_energies(root_dir='.'):
    """
    Recursively collect energy values from all .txt files
    
    Args:
        root_dir (str): Path to search (defaults to current directory)
        
    Returns:
        pandas.DataFrame: DataFrame with columns 'filename' and 'energy'
    """
    filenames = []
    energies = []
    
    # Convert to absolute path for cleaner output
    root_dir = os.path.abspath(root_dir)
    
    print(f"Searching for energy files in: {root_dir}")
    
    # Walk through all directories
    for dirpath, dirnames, filenames_in_dir in os.walk(root_dir):
        for filename in filenames_in_dir:
            if filename.endswith('.txt'):
                file_path = Path(dirpath) / filename
                try:
                    # Read the single line containing energy
                    with open(file_path, 'r') as f:
                        energy = f.readline().strip()
                    
                    # Store the relative path from root_dir
                    rel_path = os.path.relpath(file_path, root_dir)
                    filenames.append(rel_path)
                    energies.append(energy)
                except Exception as e:
                    print(f"Error reading {rel_path}: {str(e)}", file=sys.stderr)
    
    if not filenames:
        print("No .txt files found!", file=sys.stderr)
        sys.exit(1)
    
    # Create DataFrame
    df = pd.DataFrame({
        'filename': filenames,
        'energy': energies
    })
    
    return df

if __name__ == "__main__":
    # Get directory from command line arg or use current directory
    search_dir = sys.argv[1] if len(sys.argv) > 1 else '.'
    
    # Collect the data
    df = collect_energies(search_dir)
    
    # Save to CSV in current working directory
    output_file = "energy_results.csv"
    df.to_csv(output_file, index=False)
    
    print(f"\nFound {len(df)} energy files")
    print(f"Results saved to: {os.path.abspath(output_file)}")
    
    # Display first few entries
    print("\nFirst few entries:")
    print(df.head())