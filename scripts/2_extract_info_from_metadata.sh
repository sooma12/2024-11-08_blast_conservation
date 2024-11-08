#!/bin/bash

source ./config.cfg

# Write the header
echo "accession strain_name organism_name assembly_name bioproject_accession completeness contamination" > "$METADATA_EXTRACTED_TXT"

# Process each line of JSON in the input file
while IFS= read -r line; do
    # Use jq to extract fields from the current line of JSON metadata
    accession=$(echo "$line" | jq -r '.accession // "N/A"')
    assembly_name=$(echo "$line" | jq -r '.assembly_info.assembly_name // "N/A"')
    organism_name=$(echo "$line" | jq -r '.organism.organism_name // "N/A"')
    strain_name=$(echo "$line" | jq -r '.organism.infraspecific_names.strain // "N/A"')
    bioproject_accession=$(echo "$line" | jq -r '.assembly_info.bioproject_accession // "N/A"')
    completeness=$(echo "$line" | jq -r '.checkm_info.completeness // "N/A"')
    contamination=$(echo "$line" | jq -r '.checkm_info.contamination // "N/A"')

    # Append the extracted fields as a space-separated row
    echo "$accession $strain_name $organism_name $assembly_name $bioproject_accession $completeness $contamination" >> "$METADATA_EXTRACTED_TXT"
done < "$METADATA_JSON"

echo "Metadata extraction complete. Results saved in $METADATA_EXTRACTED_TXT."

