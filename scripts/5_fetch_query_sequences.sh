#!/bin/bash
#SBATCH --partition=short
#SBATCH --job-name=entrez_get_queries
#SBATCH --time=1:00:00
#SBATCH -N 1
#SBATCH -n 4
#SBATCH --output=/work/geisingerlab/Mark/blast_conservation/2024-11-08_blast_conservation/logs/%x_%j.log
#SBATCH --error=/work/geisingerlab/Mark/blast_conservation/2024-11-08_blast_conservation/logs/%x_%j.err
#SBATCH --mail-type=END
#SBATCH --mail-user=soo.m@northeastern.edu

module load anaconda3
source /shared/centos7/anaconda3/2021.05/etc/profile.d/conda.sh
conda activate /work/geisingerlab/conda_env/blast_corr

source ./config.cfg

mkdir -p $QUERY_PROTEIN_DIR

# Process one query at a time.  Get locus tag, protein ID, protein description
query_acc=`sed -n "$SLURM_ARRAY_TASK_ID"p $PROTEIN_ID_LIST |  awk '{print $1}'`
query_fa=${query_acc}.fa

# Download fasta sequence for current query protein
efetch -db protein -id ${query_acc} -format fasta > "${QUERY_PROTEIN_DIR}/${query_fa}"
sleep 3 # try to avoid hitting query rate limit