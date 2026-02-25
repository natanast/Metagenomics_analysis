# ls -la ./ | awk '{print $9}' | awk -F "_R" '{print $1}' | sort | uniq > SampleList

pathToFASTQFiles="./fastq_raw/"


printf "mkdir A_FastQC\n"
printf "mkdir B_Trimmomatic\n"
printf "mkdir C_FastQC_trimmed\n"
printf "mkdir D_Host_clean\n"
printf "mkdir E_BWA_MEGARes\n"
printf "mkdir H_krakenk2_standard\n"
printf "\n\n"


cat SampleList | while read line; do

    printf "### Sample: "
    printf $line
   	printf "  ### \n"

    # Step 1: Quality check (FastQC)
    printf "fastqc -t 4 --memory 10000 "
    printf $pathToFASTQFiles
    printf $line
    printf "_R1_001.fastq.gz "
    printf $pathToFASTQFiles
    printf $line
    printf "_R2_001.fastq.gz "
    printf " -o A_FastQC/"
    printf "\n"

    # Step 2: Trim adapters and low-quality bases (Trimmomatic)
    printf "trimmomatic "
    printf "PE -threads 4 "
    printf $pathToFASTQFiles
    printf $line
    printf "_R1_001.fastq.gz "
    printf $pathToFASTQFiles
    printf $line
    printf "_R2_001.fastq.gz "
    printf "B_Trimmomatic/"
    printf $line
    printf "_R1_paired.fastq.gz "
    printf "B_Trimmomatic/"
    printf $line
    printf "_R1_unpaired.fastq.gz "
    printf "B_Trimmomatic/"
    printf $line
    printf "_R2_paired.fastq.gz "
    printf "B_Trimmomatic/"
    printf $line
    printf "_R2_unpaired.fastq.gz "
    printf "ILLUMINACLIP:NexteraPE-PE.fa:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:20 MINLEN:36"
   	printf "\n"

	# Step 3: Quality check on trimmed (FastQC)
	printf "fastqc -t 4 --memory 10000 "
	printf "./B_Trimmomatic/"
	printf $line
	printf "_R1_paired.fastq.gz "
	printf "./B_Trimmomatic/"
	printf $line
	printf "_R2_paired.fastq.gz "
	printf " -o C_FastQC_trimmed/"
	printf "\n"

	# Step 4: Host DNA removal (BWA mapping to bovine genome)
	printf "bwa mem -t 4 /mnt/siarkou_a/groups/siarkou/Bos_taurus_genome/Bos_taurus.fna "
	printf "./B_Trimmomatic/"
	printf $line
	printf "_R1_paired.fastq.gz "
	printf "./B_Trimmomatic/"
	printf $line
	printf "_R2_paired.fastq.gz "
	printf " > D_Host_clean/"
	printf $line
	printf ".sam"
	printf "\n"

	printf "samtools view -@ 4 -bS "
	printf "D_Host_clean/"
	printf $line
	printf ".sam -o "
	printf "D_Host_clean/"
	printf $line
	printf ".bam"
	printf "\n"

	printf "samtools flagstat "
	printf "D_Host_clean/"
	printf $line
	printf ".bam > "
	printf "D_Host_clean/"
	printf $line
	printf ".report.txt"
	printf "\n"

	printf "samtools view -@ 4 -b -f 12 -F 256 "
	printf "D_Host_clean/"
	printf $line
	printf ".sam > D_Host_clean/"
	printf $line
	printf ".clean.bam"
	printf "\n"

	printf "samtools fastq "
	printf "D_Host_clean/"
	printf $line
	printf ".clean.bam -1 D_Host_clean/"
	printf $line
	printf "_clean_R1.fastq.gz -2 D_Host_clean/"
	printf $line
	printf "_clean_R2.fastq.gz"
	printf "\n"

	printf "rm "
	printf "D_Host_clean/"
	printf $line
	printf ".sam"
	printf "\n"

	printf "rm "
	printf "D_Host_clean/"
	printf $line
	printf ".bam"
	printf "\n"

	# Step 5: align to AMR
    printf "bwa mem -t 4 /mnt/siarkou_a/groups/siarkou/AMR/megares/megares.fasta "
    printf "./D_Host_clean/"
    printf $line
    printf "_clean_R1.fastq.gz "
    printf "./D_Host_clean/"
    printf $line
    printf "_clean_R2.fastq.gz "
    printf " > E_BWA_MEGARes/"
    printf $line
    printf "_amr.sam"
    printf "\n"

    printf "samtools sort "
    printf "E_BWA_MEGARes/"
    printf $line
    printf "_amr.sam -o "
    printf "E_BWA_MEGARes/"
    printf $line
    printf "_amr.sorted.bam"
    printf "\n"

    printf "samtools flagstat "
    printf "E_BWA_MEGARes/"
    printf $line
    printf "_amr.sorted.bam > "
    printf "E_BWA_MEGARes/"
    printf $line
    printf "_amr.megares.report.txt"
    printf "\n"

   	printf "samtools index "
    printf "./E_BWA_MEGARes/"
   	printf $line
	printf "_amr.sorted.bam"
	printf "\n"

    printf "rm "
    printf "E_BWA_MEGARes/"
    printf $line
    printf "_amr.sam"
    printf "\n"

	printf "\n\n"

done;

printf "featureCounts -a /mnt/siarkou_a/groups/siarkou/AMR/megares -T 16 -t gene -g gene_name -p -o megares-counts.txt ./E_BWA_MEGARes/*_amr.sorted.bam"
printf "\n"
