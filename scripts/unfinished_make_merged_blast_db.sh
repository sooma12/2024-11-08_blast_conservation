#!/bin/bash

module load anaconda3
source /shared/centos7/anaconda3/2021.05/etc/profile.d/conda.sh
conda activate /work/geisingerlab/conda_env/blast_corr

source ./config.cfg

echo 'Genome fasta files to make blast protein db:' "$FASTA_DIR/*.faa"
echo "blast db output directory: $BLAST_DB_DIR"
echo "output database name: $OUTPUT_DATABASE"

mkdir -p $BLAST_DB_DIR

echo "Adding strain IDs to fasta headers"
# Loop over each FASTA file with names like "MRSN####_proteins.faa"
for file in ${FASTA_DIR}/MRSN*_proteins.faa; do
    # Extract the MRSN number from the filename (e.g., MRSN7690 from MRSN7690_proteins.faa)
    MRSN_ID=$(basename "$file" | sed -E 's/^MRSN([0-9]+)_proteins\.faa$/MRSN\1/')
    OUTPUT_FILE="${BLAST_DB_INPUT_FA_DIR}/${MRSN_ID}_header_proteins.faa"

    # Process each header in the file to prepend the MRSN# identifier
    sed -E "s/^(>)(WP_[^ ]+)/\1${MRSN_ID}_\2/" "$file" > "$OUTPUT_FILE"

    echo "Processed $file -> $OUTPUT_FILE"
done

echo "Merging fastas"
cat ${BLAST_DB_INPUT_FA_DIR}/*.faa > $MERGED_FASTA
echo "Merged fasta saved to $MERGED_FASTA"

makeblastdb -in $MERGED_FASTA -out $OUTPUT_DATABASE -parse_seqids -dbtype prot
