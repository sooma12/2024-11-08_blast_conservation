#!/bin/bash

module load anaconda3
source /shared/centos7/anaconda3/2021.05/etc/profile.d/conda.sh
conda activate /work/geisingerlab/conda_env/blast_corr

source ./config.cfg

echo 'Genome fasta files to make blast protein db:' "$FASTA_DIR/*.faa"
echo "blast db output directory: $BLAST_DB_DIR"

mkdir -p $BLAST_DB_DIR $BLAST_DB_INPUT_FA_DIR

# Delete list of blast databases if it exists
if [ -f "${BLAST_DB_LIST}" ] ; then
  rm "${BLAST_DB_LIST}"
fi

echo "Adding strain IDs to fasta headers and making individual BLAST databases"
# Loop over each FASTA file with names like "MRSN####_proteins.faa"
for file in ${FASTA_DIR}/MRSN*_proteins.faa; do
    # Extract the MRSN number from the filename (e.g., MRSN7690 from MRSN7690_proteins.faa)
    MRSN_ID=$(basename "$file" | sed -E 's/^MRSN([0-9]+)_proteins\.faa$/MRSN\1/')
    OUTPUT_FILE="${BLAST_DB_INPUT_FA_DIR}/${MRSN_ID}_header_proteins.faa"
    BLAST_DB=${BLAST_DB_DIR}/${MRSN_ID}

    # Process each header in the file to prepend the MRSN# identifier
    sed -E "s/^(>)(WP_[^ ]+)/\1${MRSN_ID}_\2/" "$file" > "$OUTPUT_FILE"

    makeblastdb -in $OUTPUT_FILE -out $BLAST_DB -parse_seqids -dbtype prot

    echo $BLAST_DB >>$BLAST_DB_LIST

    echo "Processed $file -> $OUTPUT_FILE -> blastdb"
done



