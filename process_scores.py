import pandas as pd
import numpy as np
from pathlib import Path
from tqdm import tqdm
import re

def process_scores(scores_dir, max_n=8191):
    # Get unique PDB identifiers
    pdb_ids = set()
    for file in Path(scores_dir).glob('*_score.sc'):
        # Match pattern with or without "_output"
        match = re.search(r'(?:_output_)?([^_]+)_score\.sc', file.name)
        if match:
            pdb_id = match.group(1)
            pdb_ids.add(pdb_id)
    
    # Initialize dataframes with NaNs
    avg_df = pd.DataFrame(np.nan, index=range(max_n + 1), columns=sorted(pdb_ids))
    std_df = pd.DataFrame(np.nan, index=range(max_n + 1), columns=sorted(pdb_ids))
    
    # Process each score file
    score_files = list(Path(scores_dir).glob('*_score.sc'))
    for file in tqdm(score_files, desc="Processing score files"):
        try:
            # Extract n and pdb_id from filename, handling both patterns
            n_match = re.search(r'(\d+)(?:_output)?_', file.name)
            pdb_match = re.search(r'(?:_output_)?([^_]+)_score\.sc', file.name)
            
            if not n_match or not pdb_match:
                print(f"Skipping {file.name}: Could not extract n or pdb_id")
                continue
                
            n = int(n_match.group(1))
            pdb_id = pdb_match.group(1)
            
            # Read and process score file
            df = pd.read_csv(file, delim_whitespace=True, skiprows=1)
            total_scores = df['total_score']
            
            # Update dataframes
            avg_df.loc[n, pdb_id] = total_scores.mean()
            std_df.loc[n, pdb_id] = total_scores.std()
        except Exception as e:
            print(f"Error processing {file.name}: {e}")
            continue
    
    return avg_df, std_df 