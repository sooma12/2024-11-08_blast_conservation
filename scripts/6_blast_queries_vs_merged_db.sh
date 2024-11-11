#!/bin/bash
#SBATCH --partition=short
#SBATCH --job-name=blast
#SBATCH --time=12:00:00
#SBATCH -N 1
#SBATCH -n 4
#SBATCH --output=
#SBATCH --error=
#SBATCH --mail-type=END
#SBATCH --mail-user=soo.m@northeastern.edu

# load tools and source config

# List of databases is available

# Set blast parameters... maybe in config.

# Process one query at a time.  Get locus tag, protein ID, protein description

# For each query, blast against each of the 100 databases
# Option 1 - set blast parameters in the blast command and only take hits that meet criteria
# Option 2 - take the one "Best" hit for every query and do filtering after the fact (would let you say no hit, or hit below threshold, or hit above threshold)

# Merge outputs by query?

# Parse outputs.  Count # of hits.

# Summarize data: header line should specify blast parameters
# Table with locus tag, protein ID, protein description, # of hits
