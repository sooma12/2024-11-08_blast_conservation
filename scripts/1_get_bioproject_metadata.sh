#!/bin/bash
# Saves json version of bioproject metadata.

source ./config.cfg

module load anaconda3/2021.05
eval "$(conda shell.bash hook)"
conda activate /work/geisingerlab/conda_env/blast_corr

datasets summary genome accession --as-json-lines $BIOPROJ_ACCESSION >${METADATA_JSON}
