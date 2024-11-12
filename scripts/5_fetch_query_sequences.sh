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

# Download fasta sequence for current query protein
while IFS= read -r query_acc; do
  efetch -db protein -id ${query_acc} -format fasta > "${QUERY_PROTEIN_DIR}/${query_acc}.fa"
  sleep 3 # try to avoid hitting query rate limit
done < ${PROTEIN_ID_LIST}
