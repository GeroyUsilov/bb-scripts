import pandas as pd
import numpy as np
from pathlib import Path
from tqdm import tqdm
import re

def process_scores(scores_dir, max_n=8191):
    # Get unique PDB identifiers
    pdb_ids = set()
    for file in Path(scores_dir).glob('*_output_*_score.sc'):
        pdb_id = re.search(r'output_([^_]+)_score\.sc', file.name).group(1)
        pdb_ids.add(pdb_id)
    
    # Initialize dataframes with NaNs
    avg_df = pd.DataFrame(np.nan, index=range(max_n + 1), columns=sorted(pdb_ids))
    std_df = pd.DataFrame(np.nan, index=range(max_n + 1), columns=sorted(pdb_ids))
    
    # Process each score file
    score_files = list(Path(scores_dir).glob('*_output_*_score.sc'))
    for file in tqdm(score_files, desc="Processing score files"):
        try:
            # Extract n and pdb_id from filename
            n = int(re.search(r'(\d+)_output_', file.name).group(1))
            pdb_id = re.search(r'output_([^_]+)_score\.sc', file.name).group(1)
            
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