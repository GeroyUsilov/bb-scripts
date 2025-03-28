#!/usr/bin/env python3
"""
Organize combinatoric resfiles into subdirectories for better management.
This helps prevent issues with too many files in a single directory.
"""

import os
import shutil
import argparse
from pathlib import Path

def organize_resfiles(source_dir, target_dir, files_per_dir=1000):
    """
    Organize resfiles into subdirectories, with a maximum number of files per directory.
    
    Args:
        source_dir (str): Source directory containing resfiles
        target_dir (str): Target directory for organized files
        files_per_dir (int): Maximum number of files per subdirectory
    """
    # Create target directory
    target_path = Path(target_dir)
    target_path.mkdir(parents=True, exist_ok=True)
    
    # Get all resfiles
    resfiles = list(Path(source_dir).glob("*.txt"))
    total_files = len(resfiles)
    
    print(f"Found {total_files} resfiles")
    
    # Calculate number of subdirectories needed
    num_dirs = (total_files + files_per_dir - 1) // files_per_dir
    
    # Create subdirectories and move files
    for i in range(num_dirs):
        start_idx = i * files_per_dir
        end_idx = min((i + 1) * files_per_dir, total_files)
        
        # Create subdirectory
        subdir = target_path / f"batch_{i:03d}"
        subdir.mkdir(exist_ok=True)
        
        # Move files to subdirectory
        for resfile in resfiles[start_idx:end_idx]:
            shutil.copy2(resfile, subdir / resfile.name)
        
        print(f"Processed batch {i:03d}: {start_idx+1}-{end_idx} files")
    
    print(f"\nOrganization complete. Files are now in {num_dirs} subdirectories.")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Organize combinatoric resfiles into subdirectories")
    parser.add_argument("--source", default="combinatoric_resfiles",
                        help="Source directory containing resfiles")
    parser.add_argument("--target", default="combinatoric_resfiles_organized",
                        help="Target directory for organized files")
    parser.add_argument("--files-per-dir", type=int, default=1000,
                        help="Maximum number of files per subdirectory")
    args = parser.parse_args()
    
    organize_resfiles(args.source, args.target, args.files_per_dir) 