# ls -la ./ | awk '{print $9}' | awk -F "_R" '{print $1}' | sort | uniq > SampleList

pathToFASTQFiles="./"


printf "mkdir qualityRaw\n"
printf "mkdir trimmed\n"
printf "mkdir trimmed/fastqc_trimmed\n"
printf "mkdir bwa_output\n"
printf "mkdir bwa_amr_output\n"
printf "\n\n"


cat SampleList | while read line; do

        printf "### Sample: "
        printf $line
        printf "  ### \n"

	# Step 1: Quality check (FastQC)
	printf "fastqc -t 4 "
        printf $pathToFASTQFiles
	printf $line
        printf "_R1_001.fastq.gz "
	printf $pathToFASTQFiles
        printf $line
        printf "_R2_001.fastq.gz "
        printf " -o qualityRaw/"
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
        printf "trimmed/"
        printf $line
        printf "_R1_paired.fastq.gz "
        printf "trimmed/"
        printf $line
        printf "_R1_unpaired.fastq.gz "
        printf "trimmed/"
        printf $line
        printf "_R2_paired.fastq.gz "
        printf "trimmed/"
        printf $line
        printf "_R2_unpaired.fastq.gz "
        printf "ILLUMINACLIP:NexteraPE-PE.fa:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:20 MINLEN:36"
        printf "\n"

	# Step 3: Quality check on trimmed (FastQC)
	printf "fastqc -t 4 "
        printf $pathToFASTQFiles
	printf "trimmed/"
        printf $line
        printf "_R1_paired.fastq.gz "
        printf $pathToFASTQFiles
	printf "trimmed/"
        printf $line
        printf "_R2_paired.fastq.gz "
        printf " -o trimmed/fastqc_trimmed/"
        printf "\n"

    	# Step 4: Host DNA removal (BWA mapping to bovine genome)
	printf "bwa mem -t 4 /mnt/siarkou_a/groups/siarkou/Bos_taurus_genome/Bos_taurus.fna "
	printf "./trimmed/"
	printf $line
	printf "_R1_paired.fastq.gz "
	printf "./trimmed/"
	printf $line
	printf "_R2_paired.fastq.gz "
	printf " > bwa_output/"
	printf $line
	printf ".sam"
	printf "\n"

	printf "samtools view -@ 4 -bS "
	printf "bwa_output/"
	printf $line
	printf ".sam -o "
	printf "bwa_output/"
	printf $line
	printf ".bam"
	printf "\n"

	printf "samtools flagstat "
	printf "bwa_output/"
	printf $line
	printf ".bam > "
	printf "bwa_output/"
	printf $line
	printf ".report.txt"
	printf "\n"

	printf "samtools view -@ 4 -b -f 12 -F 256 "
	printf "bwa_output/"
	printf $line
	printf ".sam > bwa_output/"
	printf $line
	printf ".clean.bam"
	printf "\n"

	printf "samtools fastq -@ 4 "
	printf "bwa_output/"
	printf $line
	printf ".clean.bam -1 bwa_output/"
	printf $line
	printf "_clean_R1.fastq -2 bwa_output/"
	printf $line
	printf "_clean_R2.fastq"
	printf "\n"


        # Step 5: align to AMR
        printf "bwa mem -t 4 /mnt/siarkou_a/groups/siarkou/AMR/AMR_CDS.fa "
        printf "./bwa_output/"
        printf $line
        printf "_clean_R1.fastq "
        printf "./bwa_output/"
        printf $line
        printf "_clean_R2.fastq "
        printf " > bwa_amr_output/"
        printf $line
        printf "_amr.sam"
        printf "\n"

        printf "samtools view -@ 4 -bS "
        printf "bwa_amr_output/"
        printf $line
        printf "_amr.sam -o "
        printf "bwa_amr_output/"
        printf $line
        printf "_amr.bam"
        printf "\n"

        printf "samtools sort "
        printf "bwa_amr_output/"
        printf $line
        printf "_amr.sam -o "
        printf "bwa_amr_output/"
        printf $line
        printf "_amr.sorted.bam"
        printf "\n"

        printf "samtools flagstat "
        printf "bwa_amr_output/"
        printf $line
        printf "_amr.sorted.bam > "
        printf "bwa_amr_output/"
        printf $line
        printf "_amr.report.txt"
        printf "\n"


        printf "\n\n"

done;


printf "\n\n"

printf "featureCounts"
printf " -a ./ΑMR/annotation/AMR_CDS_simplified.gff "
printf " -T 16 "
printf " -t gene "
printf " -g gene_name "
printf " -p"
printf " -o amr-counts.txt "
printf "./bwa_amr_output/*_amr.sorted.bam"
printf "\n"

printf "\n\n"

printf "### PIPELINE COMPLETE ###\n"
