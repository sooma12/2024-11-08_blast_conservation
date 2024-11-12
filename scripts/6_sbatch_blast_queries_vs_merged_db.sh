#!/bin/bash
#SBATCH --partition=short
#SBATCH --job-name=blast
#SBATCH --time=12:00:00
#SBATCH -N 1
#SBATCH -n 4
#SBATCH --array=1-286%12
#SBATCH --output=/work/geisingerlab/Mark/blast_conservation/2024-11-08_blast_conservation/logs/%x-%y.log
#SBATCH --error=/work/geisingerlab/Mark/blast_conservation/2024-11-08_blast_conservation/logs/%x-%y.err
#SBATCH --mail-type=END
#SBATCH --mail-user=soo.m@northeastern.edu

# wc -l BfmR_Direct_Target_ProteinIDs.txt
# 285

# load tools and source config
module load anaconda3
source /shared/centos7/anaconda3/2021.05/etc/profile.d/conda.sh
conda activate /work/geisingerlab/conda_env/blast_corr

source ./config.cfg

mkdir -p $QUERY_PROTEIN_DIR $BLAST_INTERMEDIATE_OUTDIR

# List of databases is available
# $BLAST_DB_LIST is a test file with a list of the blast database names
# e.g. `/work/geisingerlab/Mark/blast_conservation/2024-11-08_blast_conservation/blastdb/MRSN960`

# Process one query at a time.  Get locus tag, protein ID, protein description
query_acc=`sed -n "$SLURM_ARRAY_TASK_ID"p $PROTEIN_ID_LIST |  awk '{print $1}'`
query_fa=${query_acc}.fa
query_hits=${query_acc}_hits.txt

# Download fasta sequence for current query protein
efetch -db protein -id ${query_acc} -format fasta > ${QUERY_PROTEIN_DIR}/${query_fa}

# For current query, blast vs. all 100 sequences.  Output each result to a separate file
mkdir -p ${BLAST_INTERMEDIATE_OUTDIR}/${query_acc}
# Read in list of blast databases
while IFS= read -r database; do
  blastp -query ${QUERY_PROTEIN_DIR}/${query_fa} -db ${database} -out ${BLAST_INTERMEDIATE_OUTDIR}/${query_acc}/$(basename $database).txt -outfmt 6
done < ../${BLAST_DB_LIST}

# From each blast output, pick the best hit.  Send to a new file.
if [ -f "${query_hits}" ] ; then
  rm "${query_hits}"
fi

for file in ${BLAST_INTERMEDIATE_OUTDIR}/${query_acc}/*.txt; do
  # Check if file has contents
  if [[ -s $file ]]; then
        # Extract the first line (best hit) and append to output_file
        head -n 1 "$file" >> "${BLAST_INTERMEDIATE_OUTDIR}/top_hits/$query_hits"
    else
        echo "$file is empty. Skipping."
    fi
done
