# ls -la ./ | awk '{print $9}' | awk -F "_R" '{print $1}' | sort | uniq > SampleList

pathToFASTQFiles="./fastq_raw/"


printf "mkdir A_FastQC\n"
printf "mkdir B_Trimmomatic\n"
printf "mkdir C_FastQC_trimmed\n"
printf "mkdir D_Host_clean\n"
printf "mkdir H_krakenk2_standard\n"
printf "mkdir kraken2_16_output\n"
printf "mkdir bracken_output\n"
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

	printf "samtools sort -n -@ 4 D_Host_clean/"
	printf $line
	printf ".clean.bam -o D_Host_clean/"
	printf $line
	printf ".clean.qsort.bam"
	printf "\n"

	printf "samtools fastq "
	printf "D_Host_clean/"
	printf $line
	printf ".clean.qsort.bam -1 D_Host_clean/"
	printf $line
	printf "_clean_R1.fastq -2 D_Host_clean/"
	printf $line
	printf "_clean_R2.fastq -0 /dev/null -s /dev/null -n"
	printf "\n"

	printf "gzip -f D_Host_clean/"
	printf $line
	printf "_clean_R1.fastq D_Host_clean/"
	printf $line
	printf "_clean_R2.fastq"
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

	# Step 5: kraken2 analysis    
	printf "kraken2 --db /mnt/siarkou_a/groups/siarkou/kraken2_db_standard_16/"
	printf " --threads 32 --paired --gzip-compressed --confidence 0.1 --minimum-hit-groups 3"
	printf " --report kraken2_16_output/"
	printf $line
	printf ".report"
	printf " --output kraken2_16_output/"
	printf $line
	printf ".out "
	printf " D_Host_clean/"
	printf $line
	printf "_clean_R1.fastq.gz D_Host_clean/"
	printf $line
	printf "_clean_R2.fastq.gz"
    printf "\n"

	printf "bracken -d /mnt/siarkou_a/groups/siarkou/kraken2_db_standard_16/"
	printf " -i kraken2_16_output/"
	printf $line
	printf ".report -o bracken_output/"
	printf $line
	printf ".bracken -w bracken_output/"
	printf $line
	printf ".breport -r 150 -l S -t 10"
	printf "\n"

	printf "rm kraken2_16_output/"
	printf $line
	printf ".out"
	printf "\n"

	printf "\n\n"

done;
