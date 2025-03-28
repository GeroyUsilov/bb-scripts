#!/usr/bin/env python3
"""
Collect Rosetta score files from output directories and copy them to the scores directory.
"""

import os
import glob
import shutil
import argparse
from datetime import datetime

def collect_score_files(source_dir, target_dir):
    """
    Find all Rosetta score files (*.sc) in the source directory and its subdirectories,
    and copy them to the target directory with renamed filenames to prevent overwriting.
    
    Args:
        source_dir (str): Source directory to search for score files
        target_dir (str): Target directory to copy score files to
    """
    # Create target directory if it doesn't exist
    os.makedirs(target_dir, exist_ok=True)
    
    # Find all .sc files in the source directory
    score_files = glob.glob(os.path.join(source_dir, "**", "*.sc"), recursive=True)
    
    # Copy each file to the target directory with a unique name
    copied_count = 0
    for file_path in score_files:
        # Generate a unique name based on the file's directory structure
        relative_path = os.path.relpath(file_path, source_dir)
        # Replace path separators with underscores
        unique_name = relative_path.replace(os.path.sep, "_")
        
        # Copy the file
        target_path = os.path.join(target_dir, unique_name)
        shutil.copy2(file_path, target_path)
        copied_count += 1
        print(f"Copied: {file_path} -> {target_path}")
    
    print(f"Collected {copied_count} score files.")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Collect Rosetta score files")
    parser.add_argument("--source", default="results/structures", 
                        help="Source directory containing score files (default: results/structures)")
    parser.add_argument("--target", default="results/scores", 
                        help="Target directory to copy score files to (default: results/scores)")
    args = parser.parse_args()
    
    collect_score_files(args.source, args.target) 