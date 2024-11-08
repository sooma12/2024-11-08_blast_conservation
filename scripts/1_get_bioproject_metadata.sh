#!/bin/bash
# Saves json version of bioproject metadata.

source ./config.cfg

eval "$(conda shell.bash hook)"
conda activate /work/geisingerlab/conda_env/blast_corr

datasets summary genome accession --as-json-lines $BIOPROJ_ACCESSION >${METADATA}
