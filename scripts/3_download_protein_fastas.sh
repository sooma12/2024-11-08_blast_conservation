#!/bin/bash

source ./config.cfg

# Output directory for protein FASTA files
mkdir -p "$FASTA_DIR"

# Parse the file and download each protein FASTA
awk 'NR > 1 {print $1, $2}' "$METADATA_EXTRACTED_TXT" | while read -r accession organism_name; do
    # Clean the organism name for use as a filename
    sanitized_name=$(echo "$organism_name" | tr ' ' '_' | tr -d '[:punct:]')
    output_file="${FASTA_DIR}/${sanitized_name}_proteins.faa"

    # Download the protein FASTA file for the given accession
    echo "Downloading protein FASTA for $accession ($organism_name)..."
    datasets download protein genome "$accession" --include fasta --output "${output_file}.zip"

    # Unzip the downloaded file and move the protein file to the desired filename
    unzip -o "${output_file}.zip" -d "$FASTA_DIR"
    find "$FASTA_DIR/ncbi_dataset/data/$accession" -name "*.faa" -exec mv {} "$output_file" \;

    # Clean up the zip and temporary files
    rm -rf "${output_file}.zip" "$FASTA_DIR/ncbi_dataset"
done

echo "Protein FASTA downloads complete. Files saved in $FASTA_DIR."

