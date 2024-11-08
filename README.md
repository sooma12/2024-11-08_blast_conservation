# BLAST for conservation of proteins in A. baumannii genomes

## Specs

From EG:

Use local command line BLAST to check for conservation of a set of proteins in A. baumannii genomes

Set of A. baumannii genomes from https://journals.asm.org/doi/10.1128/aac.00840-20

Genomes are available at: https://www.ncbi.nlm.nih.gov/datasets/genome/?bioproject=PRJNA545079

## Methods notes

1. Using ncbi datasets, download Bioproject metadata for PRJNA545079 -> to json
2. 


## From ChatGPT:

To download Acinetobacter baumannii genomes from NCBI using command-line tools (like Entrez Direct) and then filter them for high-quality genomes (>99% completeness and <1% contamination), you can follow this step-by-step guide. The process will involve downloading the genomes and then assessing their quality using an external tool like CheckM for filtering.


Step 2: Search for Acinetobacter baumannii Assemblies
You can use the esearch and efetch utilities to search for Acinetobacter baumannii genomes in NCBI and download their metadata.

```bash
# Search for Acinetobacter baumannii assemblies and retrieve assembly summaries
esearch -db assembly -query "Acinetobacter baumannii" | esummary | xtract -pattern DocumentSummary -element FtpPath_RefSeq > acinetobacter_genomes.txt
```

This will give you a list of FTP links for downloading genome assemblies for Acinetobacter baumannii.

Step 3: Download Genomes
Use wget or curl to download the genome sequences (.fna files) from the FTP URLs. These are the complete or draft genome assemblies.

bash
Copy code
# Loop over the URLs and download the genome assemblies
for url in $(cat acinetobacter_genomes.txt); do
    genome_url="${url}/$(basename ${url})_genomic.fna.gz"
    wget $genome_url
done
Step 4: Install CheckM for Genome Quality Assessment
To assess the quality of the genomes, you'll need a tool like CheckM that can estimate genome completeness and contamination based on lineage-specific marker sets. Install CheckM:

bash
Copy code
# Install CheckM using conda (if you have Conda installed)
conda install -c bioconda checkm-genome

# Alternatively, install with pip
pip install checkm-genome
Step 5: Assess Genome Quality with CheckM
Now that you have the genome sequences, you can use CheckM to evaluate their completeness and contamination. First, create a directory to organize the genome data for CheckM.

bash
Copy code
mkdir checkm_input
mv *.fna.gz checkm_input/
gunzip checkm_input/*.gz  # Unzip the genome files
Run CheckM to estimate genome completeness and contamination. CheckM requires a directory structure with genomes in subdirectories:

bash
Copy code
# Run CheckM lineage_wf to assess completeness and contamination
checkm lineage_wf checkm_input checkm_output -x fna
This will generate a report with metrics like completeness and contamination for each genome.

Step 6: Filter Genomes Based on Quality
CheckM outputs a table in checkm_output that includes completeness and contamination values. You can filter this table to keep only genomes that meet your criteria (>99% completeness and <1% contamination).

bash
Copy code
# Use awk to filter genomes based on the quality criteria
awk -F '\t' '$12 > 99 && $13 < 1 {print $0}' checkm_output/storage/bin_stats_ext.tsv > high_quality_genomes.txt
Step 7: Download High-Quality Genomes
The filtered output high_quality_genomes.txt contains information about the high-quality genomes. Use this to download only those genomes:

bash
Copy code
# Extract genome names or paths to download filtered genomes
awk '{print $1}' high_quality_genomes.txt | while read genome; do
    wget "ftp://ftp.ncbi.nlm.nih.gov/genomes/all/$genome.fna.gz"
done
Summary of Commands:
Search for Acinetobacter baumannii genomes:

bash
Copy code
esearch -db assembly -query "Acinetobacter baumannii" | esummary | xtract -pattern DocumentSummary -element FtpPath_RefSeq > acinetobacter_genomes.txt
Download genome assemblies:

bash
Copy code
for url in $(cat acinetobacter_genomes.txt); do
    genome_url="${url}/$(basename ${url})_genomic.fna.gz"
    wget $genome_url
done
Run CheckM to assess genome quality:

bash
Copy code
checkm lineage_wf checkm_input checkm_output -x fna
Filter genomes for >99% completeness and <1% contamination:

bash
Copy code
awk -F '\t' '$12 > 99 && $13 < 1 {print $0}' checkm_output/storage/bin_stats_ext.tsv > high_quality_genomes.txt
This process will allow you to download and filter Acinetobacter baumannii genomes from NCBI based on their completeness and contamination values using command-line tools.







## Other papers that do similar work

https://academic.oup.com/nar/advance-article/doi/10.1093/nar/gkae668/7734169
Sequence conservation analysis
10 998 draft Acinetobacter spp. genomes were downloaded from RefSeq (52). BLASTN version 2.14.1 + searches of the A. baumannii and A. baylyi aar sequences were performed against these draft genomes using default settings (53). Lower percentage identity hits were filtered out to determine which regions of aar were subject to sequence divergence. A multiple sequence alignment of combined A. baumannii and A. baylyi hits was performed using Clustal Omega version 1.2.4 (54). Jalview version 2.11.2.7 was then used to view this alignment and to cluster the samples using average distance (55). Visualisation of these clusters was then performed using iTOL version 6.8.1 (56). The Jalview conservation score was then exported as a text file and R was used to generate a conservation plot (R Core Team (2023) (57)).

https://www.frontiersin.org/journals/microbiology/articles/10.3389/fmicb.2023.1177951/full
Genome source and analysis of Acinetobacter strains
As of March 2021, there were 1,631 Acinetobacter strains with published genome sequences in the GenBank. The qualities of the downloaded 1,631 genome sequences were verified using CheckM (Parks et al., 2015). To ensure the accuracy of the analysis, only 312 genomes with completion >99% and contamination <1% were selected for further phylogenomic and comparative genomic analyses. More detailed information on the 312 Acinetobacter genomes is listed in Supplementary Table S1. Among them, 207 strains were isolated from clinical-related habitats, 32 strains from animal-related habitats, and 73 strains from environmental habitats. The clinical strains include those isolated from places related to hospitals, such as hospital sewage, urine, blood, sputum, wounds, and ears among others. The animal strains were isolated from animal meats and animal feces. Environmental strains refer to strains isolated from the natural environment, including soil, sludge, and water among others.

Acinetobacter currently includes 74 species with valid published names, but 90 of the genomes used in this study have not been assigned to a specific species of Acinetobacter. To elucidate the accurate taxonomic position of the unassigned Acinetobacter strains, the average nucleotide identity based on BLAST (ANIb) values were calculated using the online ANI calculator1 (Richter et al., 2016). The digital DNA–DNA hybridization (dDDH) values were calculated using the Genome to Genome Distance Calculator (GGDC 2.5)2 (Auch et al., 2010). An ANIb value above 95% for two organisms and a dDDH value above 70% indicate that they belong to the same species (Chun et al., 2018).
