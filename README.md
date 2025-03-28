# Protein Structure Design Scripts

This repository contains scripts for protein structure design and analysis using Rosetta.

## Directory Structure

```
bb-scripts/
├── data/               # Input data files
│   ├── pdb_files/      # PDB structure files
│   ├── pdb_NMR_files/  # NMR structure files
│   └── resfiles/       # Rosetta design specification files
├── scripts/            # Shell and Python scripts
│   ├── extract_model1.py      # Extract model 1 from NMR ensemble
│   ├── run_amber.sh           # Run AMBER simulations
│   ├── run_fixbb.sh           # Run Rosetta fixbb protocol
│   ├── submit_fixbb.sh        # Slurm submission script for fixbb
│   ├── submission_loop.sh     # Submit multiple design jobs
│   ├── make_resfiles.py       # Script version of make_resfiles notebook
│   ├── collect_scores.py      # Collect score files from output directories
│   ├── convert_notebook.py    # Convert Jupyter notebooks to Python scripts
│   ├── runtask_combinatoric.sh    # Run fixbb on a single combinatoric resfile
│   └── parallel_combinatoric.sbatch # Submit parallel jobs for combinatoric resfiles
├── notebooks/          # Jupyter notebooks
│   ├── make_resfiles.ipynb    # Generate resfiles for design
│   └── analysis/             # Analysis notebooks
│       └── rosetta_analysis.ipynb  # Analyze Rosetta scores
└── results/            # Output files
    ├── scores/         # Collected Rosetta scores
    └── structures/     # Output structure files
```

## Workflow

1. **Prepare structures**: Convert NMR ensembles to single models using `extract_model1.py`
2. **Create design files**: Generate resfiles using `make_resfiles.ipynb` or `make_resfiles.py`
3. **Run design**: Submit Rosetta fixbb jobs using `submission_loop.sh`
4. **Collect results**: Gather score files using `collect_scores.py`
5. **Analyze results**: Process and visualize results with `rosetta_analysis.ipynb`

## Usage

### Running on HPC with Slurm

The scripts are designed to run on an HPC system with Slurm scheduler:

```bash
# Submit all design jobs
./scripts/submission_loop.sh

# Submit a single design job
sbatch ./scripts/submit_fixbb.sh data/pdb_files/1pga.pdb data/resfiles/GBWT.txt

# Run fixbb on all combinatoric resfiles in parallel
sbatch ./scripts/parallel_combinatoric.sbatch
```

### Utility Scripts

```bash
# Convert a notebook to a Python script
./scripts/convert_notebook.py notebooks/my_notebook.ipynb scripts/my_script.py

# Collect score files from output directories
./scripts/collect_scores.py --source results/structures --target results/scores
```

### Local Analysis

Analysis can be performed locally using Jupyter notebooks:

```bash
jupyter notebook notebooks/analysis/rosetta_analysis.ipynb
```

## Combinatoric Resfiles

For running fixbb on a large number of combinatoric resfiles:

1. Place all combinatoric resfiles in the `combinatoric_resfiles` directory
2. Submit all jobs in parallel:
   ```bash
   sbatch ./scripts/parallel_combinatoric.sbatch
   ```
3. Results will be organized in `combinatoric_results/<resfile_name>_output/`
4. Use `collect_scores.py` to gather all score files:
   ```bash
   ./scripts/collect_scores.py --source combinatoric_results --target results/scores
   ``` 