# BLAST for conservation of proteins in A. baumannii genomes

## Specs

From EG:

Use local command line BLAST to check for conservation of a set of proteins in A. baumannii genomes

Set of A. baumannii genomes from https://journals.asm.org/doi/10.1128/aac.00840-20

Genomes are available at: https://www.ncbi.nlm.nih.gov/datasets/genome/?bioproject=PRJNA545079

## Methods notes

Eddie's `BfmR_Direct_Target_ProteinIDs.txt` has windows-style carriage returns that are messing up BLAST.

Fixed using: `sed -i 's/\r$//' BfmR_Direct_Target_ProteinIDs.txt`

1. Using ncbi datasets, download Bioproject metadata for PRJNA545079 -> to json
2. Extract Bioproject metadata file and extract accession numbers for individual A. baumannii genomes
3. Using accession numbers of the A. baumannii strains, download protein fasta files (note, used GCF_ accession numbers)
4. Run makebastdb to make one BLAST database for each strain's proteins
5. Get query sequences corresponding to WP_ and YP_ protein identifier numbers contained in `BfmR_Direct_Target_ProteinIDs.txt`
6. For each query sequence, BLASTp search against each of the 100 databases for the strains.  This script then grabs the top hit in each output (corresponding to the lowest E value) and concatenates all of the results for the 100 strains.  This produces a "top hits" file for each BfmR direct target containing the best hit by evalue from every strain.  For 11/12/2024, I did not use a minimum e value cutoff.
7. Python script to process BLASTp output.  On discovery, requires `conda activate /work/geisingerlab/conda_env/blast_corr` for Python packages.


## Other papers that do similar work

https://academic.oup.com/nar/advance-article/doi/10.1093/nar/gkae668/7734169
Sequence conservation analysis
10 998 draft Acinetobacter spp. genomes were downloaded from RefSeq (52). BLASTN version 2.14.1 + searches of the A. baumannii and A. baylyi aar sequences were performed against these draft genomes using default settings (53). Lower percentage identity hits were filtered out to determine which regions of aar were subject to sequence divergence. A multiple sequence alignment of combined A. baumannii and A. baylyi hits was performed using Clustal Omega version 1.2.4 (54). Jalview version 2.11.2.7 was then used to view this alignment and to cluster the samples using average distance (55). Visualisation of these clusters was then performed using iTOL version 6.8.1 (56). The Jalview conservation score was then exported as a text file and R was used to generate a conservation plot (R Core Team (2023) (57)).

https://www.frontiersin.org/journals/microbiology/articles/10.3389/fmicb.2023.1177951/full
Genome source and analysis of Acinetobacter strains
As of March 2021, there were 1,631 Acinetobacter strains with published genome sequences in the GenBank. The qualities of the downloaded 1,631 genome sequences were verified using CheckM (Parks et al., 2015). To ensure the accuracy of the analysis, only 312 genomes with completion >99% and contamination <1% were selected for further phylogenomic and comparative genomic analyses. More detailed information on the 312 Acinetobacter genomes is listed in Supplementary Table S1. Among them, 207 strains were isolated from clinical-related habitats, 32 strains from animal-related habitats, and 73 strains from environmental habitats. The clinical strains include those isolated from places related to hospitals, such as hospital sewage, urine, blood, sputum, wounds, and ears among others. The animal strains were isolated from animal meats and animal feces. Environmental strains refer to strains isolated from the natural environment, including soil, sludge, and water among others.

Acinetobacter currently includes 74 species with valid published names, but 90 of the genomes used in this study have not been assigned to a specific species of Acinetobacter. To elucidate the accurate taxonomic position of the unassigned Acinetobacter strains, the average nucleotide identity based on BLAST (ANIb) values were calculated using the online ANI calculator1 (Richter et al., 2016). The digital DNA–DNA hybridization (dDDH) values were calculated using the Genome to Genome Distance Calculator (GGDC 2.5)2 (Auch et al., 2010). An ANIb value above 95% for two organisms and a dDDH value above 70% indicate that they belong to the same species (Chun et al., 2018).
