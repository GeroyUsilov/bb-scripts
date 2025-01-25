#!/bin/bash

# Input PDB file
pdb_file=$1

if [ -z "$pdb_file" ]; then
    echo "Usage: $0 <pdb_file>"
    exit 1
fi

# Base name for output files
base_name=$(basename "$pdb_file" .pdb)

# Create tleap input file
cat > leap.in << EOF
source leaprc.protein.ff14SB
mol = loadpdb ${pdb_file}
saveamberparm mol ${base_name}.prmtop ${base_name}.inpcrd
quit
EOF

# Run tleap to generate topology and coordinate files
tleap -f leap.in

# Create minimization input file
cat > min.in << EOF
Single point energy calculation
 &cntrl
  imin=5,        ! Single point energy calculation (no minimization)
  ntb=0,         ! No periodic boundary
  maxcyc=0,      ! No minimization steps
  cut=999.0,     ! Effectively infinite cutoff
 /
EOF

# Run sander to calculate energy
sander -O -i min.in -o ${base_name}_energy.out -p ${base_name}.prmtop -c ${base_name}.inpcrd

# Extract and format the energy
echo "Energy for ${pdb_file}:"
grep "FINAL" ${base_name}_energy.out

# Clean up intermediate files
rm leap.log min.in leap.in