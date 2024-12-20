# 7_process_top_blast_hits.py
# MWS 12 November 2024
"""
Take a list of protein accession numbers corresponding to BfmR hits,
those proteins' FASTA files, BLASTp output tables corresponding to the top hit
in several A. baumannii genomes, and values for BLASTp % identity and length cutoffs.

Output a table of query protein accession number (BfmR hits), protein length,
and percent of genomes that have a hit that pass the % identity and length cutoff
"""


import argparse
import os
import pandas as pd
from Bio import SeqIO


def main():
    args = get_args()
    prot_ids = _get_query_accession_list(query_file=args.query_list)
    protein_data = []  # will be a list of dictionaries
    blastdb_count = _count_blast_databases(args.blastdb_dir)

    for prot_id in prot_ids:
        fasta_description, fasta_length = get_query_details_from_fa(query_fastas_path=args.query_fasta_dir,
                                                                    protein_id=prot_id)
        blast_hits_over_threshold = count_hits_above_threshold(top_hits_directory=args.top_hits_dir,
                                                               protein_id=prot_id,
                                                               protein_length=fasta_length,
                                                               identity_threshold=args.percent_identity,
                                                               length_threshold=args.percent_length)
        protein_data.append({'query_id': str(prot_id),
                             'query_description': str(fasta_description).replace(prot_id, "").strip(),
                             'query_length': fasta_length,
                             'fraction_blast_hits_above_thresholds': round(blast_hits_over_threshold / blastdb_count, 2)})

    df = pd.DataFrame(protein_data)

    metadata_line = f'### Protein queries: {args.query_list}; % identity cutoff {args.percent_identity}; ' \
                    f'% length cutoff {args.percent_length}; number of subject strains {blastdb_count}\n'

    # Add metadata to first line of output file
    with open(args.outfile, 'w') as f:
        f.write(metadata_line)

    df.to_csv(args.outfile, mode='a', header=True, index=False)


def get_args():
    """Return parsed command-line arguments."""

    parser = argparse.ArgumentParser(
        description="Finds first ORF in each sequence in a FASTA file and returns their protein translations.",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter)

    parser.add_argument('-q', '--query_list',  # variable to access this data later: args.query_list
                        required=True,
                        help='Filepath to text file listing query protein accession IDs, e.g. BfmR direct targets list',
                        type=str)

    parser.add_argument('-f', '--query_fasta_dir',  # variable to access this data later: args.query_list
                        required=True,
                        help='Filepath to directory containing query fasta files with files named {protein_id}.fa',
                        type=str)

    parser.add_argument('-b', '--blastdb_dir',  # variable to access this data later: args.query_list
                        required=True,
                        help='Filepath to directory containing BLAST protein databases.  '
                             'Assumes there are ".pos" files in database directory.',
                        type=str)

    parser.add_argument('-t', '--top_hits_dir',  # variable to access this data later: args.query_list
                        required=True,
                        help='Filepath to directory containing merged BLAST top hit output files, '
                             'titled "{protein_id}_top_hits.txt',
                        type=str)

    parser.add_argument('-o', '--outfile',  # variable to access this data later: args.outfile
                        required=True,
                        help='Filepath for output',
                        type=str)

    parser.add_argument('-i', '--percent_identity',  # variable to access this data later: args.percent_identity
                        required=True,
                        help='Minimum BLASTp percent identity threshold',
                        type=float)

    parser.add_argument('-l', '--percent_length',  # variable to access this data later: args.percent_length
                        required=True,
                        help='Minimum BLASTp length threshold',
                        type=float)

    return parser.parse_args()


# Process input file with queries into a list
def _get_query_accession_list(query_file):
    """ return list of protein IDs from query input file """

    protein_ids = []

    with open(query_file, 'r') as query_fh:
        for line in query_fh:
            line = line.strip()
            if (line.startswith("WP_") or line.startswith("YP_")) and len(line.split()) == 1:
                protein_ids.append(line)
            else:
                print("error on line: " + line)

    return protein_ids


def get_query_details_from_fa(query_fastas_path, protein_id):
    """ open a fasta file corresponding to protein id and save description and length of the protein """
    file_path = os.path.join(query_fastas_path, f"{protein_id}.fa")
    if os.path.isfile(file_path):
        try:
            with open(file_path, 'r') as file:
                records = list(SeqIO.parse(file, "fasta"))
                if len(records) != 1:
                    print(f"Warning: Fasta file {file_path} contains {len(records)} fasta entries instead of 1.")
                record = records[0]
                protein_name = record.description
                sequence_length = len(record.seq)
        except FileNotFoundError:
            print(f"failed to open file for {protein_id}")
    else:
        return 'NA', 'NA'
    return protein_name, sequence_length


def count_hits_above_threshold(top_hits_directory, protein_id, protein_length: float,
                               identity_threshold: float, length_threshold: float):
    file_path = os.path.join(top_hits_directory, f"{protein_id}_top_hits.txt")
    high_quality_count = 0

    if os.path.isfile(file_path):
        with open(file_path, 'r') as fh:
            for line in fh:
                columns = line.strip().split('\t')
                try:
                    percent_identity = float(columns[2])
                    match_length = int(columns[3])

                    # Calculate current match's percent of the full protein
                    match_length_percent = (match_length / protein_length) * 100

                    # Check both percent identity and match % length of total
                    if percent_identity >= identity_threshold and match_length_percent >= length_threshold:
                        high_quality_count += 1
                except (ValueError, IndexError):
                    print(f"Warning: Skipping malformed line in {file_path}: {line}")
    else:
        print(f"Warning: File {file_path} does not exist.")

    return high_quality_count


def _count_blast_databases(blastdb_dir):
    count = 0
    for filename in os.listdir(blastdb_dir):
        if filename.endswith(".pos"):
            count += 1
    return count


if __name__ == "__main__":
    main()
