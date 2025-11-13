# ls -la /work/natanastas/Merge/20250127 | awk '{print $9}' | awk -F "_L" '{print $1}' | sort | uniq > SampleList
pathToFASTQFiles="/mnt/new_home/kate_mallou/Karolinska_RNASeq/"


# Create directories
printf "mkdir qualityRaw\n"
printf "mkdir trimmed\n"
printf "mkdir bwa_output\n"
printf "mkdir amrplusplus_results\n"
printf "\n\n"

# Load environment
printf "source activate metagenomics_env"
printf "\n\n"

# Loop through each sample
cat $SampleList | while read line; do

    printf "### $line ###\n"

	# Step 1: Quality control (FastQC)
	printf "fastqc \
	-t $numberOfThreads \
	$pathToFASTQFiles/$line*R1*.fastq.gz \
	$pathToFASTQFiles/$line*R2*.fastq.gz \
	-o ./quality/raw/ \
	\n"

	# Step 2: Trim adapters and low-quality bases (Trimmomatic)
	printf "trimmomatic \
	PE -threads 16 \
	$pathToFASTQFiles/$line*R1*.fastq.gz \
	$pathToFASTQFiles/$line*R2*.fastq.gz \
	trimmed/$line*R1*paired.fastq.gz trimmed/$line*R1*unpaired.fastq.gz \
	trimmed/$line*R2*paired.fastq.gz trimmed/$line*R2*unpaired.fastq.gz \
	ILLUMINACLIP:TruSeq3-PE.fa:2:30:10 \
	LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36 \
	\n"

    # Step 3: Host DNA removal (BWA mapping to bovine genome)
	printf "bwa mem -t 16 /path/to/bos_taurus.fa \
	trimmed/$line*R1*paired.fastq.gz \
	trimmed/$line*R2*paired.fastq.gz > bwa_output/$line.sam
	\n"

	printf "samtools view 	  -@ 16 -bS $line.Aligned.out.sam -o $line.bam \n"
	printf "samtools flagstat -@ 16 $line.bam > $line.report.txt \n"
	printf "samtools view 	  -@ 16 -b -f 12 -F 256 bwa_output/$line.sam > bwa_output/$line.clean.bam \n"
	printf "fastq 			  -@ 16 bwa_output/$line.clean.bam -1 bwa_output/$line*_clean_R1.fastq -2 bwa_output/$line*_clean_R2.fastq \n"

	# Step 4: ARG mapping (BWA to MEGARes)
	printf "bwa mem -t 16 /path/to/MEGARes_v1.01.fasta \
	bwa_output/$line*clean_R1.fastq \
	bwa_output/$line*clean_R2.fastq > bwa_output/$line.ARG.sam
	\n"

	printf "samtools view     -@ 16 -bS bwa_output/$line.ARG.sam -o bwa_output/$line.ARG.bam \n"
	printf "samtools flagstat -@ 16 bwa_output/$line.ARG.bam > bwa_output/$line.ARG.report.txt \n"
	printf "samtools view 	  -@ 16 -b -F 4 bwa_output/$line.ARG.bam -o bwa_output/$line.ARG.mapped.bam \n"
	printf "samtools sort     -@ 16 bwa_output/$line.ARG.mapped.bam -o bwa_output/$line.ARG.mapped.sorted.bam \n"

    # Step 5: Resistome profiling with AmrPlusPlus
	printf "AmrPlusPlus -i bwa_output/${line}.ARG.mapped.sorted.bam -o amrplusplus_results/${line}/ \n"

	printf "\n\n"

done

# Deactivate environment
conda deactivate
