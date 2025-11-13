# Download FASTA genome (chromosomes + scaffolds)
wget ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/002/263/795/GCF_002263795.1_ARS-UCD1.2/GCF_002263795.1_ARS-UCD1.2_genomic.fna.gz

# Unzip
gunzip GCF_002263795.1_ARS-UCD1.2_genomic.fna.gz

# Rename for convenience
mv GCF_002263795.1_ARS-UCD1.2_genomic.fna bos_taurus.fa

# Index genome for BWA
bwa index bos_taurus.fa



# Download MEGARes database for AMR gene identification
wget https://megares.meglab.org/downloads/megares_v1.01.fasta

# Index MEGARes database
bwa index MEGARes_v1.01.fasta
