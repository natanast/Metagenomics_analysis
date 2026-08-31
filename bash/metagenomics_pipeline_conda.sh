# ls -la ./ | awk '{print $9}' | awk -F "_R" '{print $1}' | sort | uniq > SampleList

pathToFASTQFiles="./fastq_raw/"


printf "mkdir A_FastQC\n"
printf "mkdir B_Trimmomatic\n"
printf "mkdir C_FastQC_trimmed\n"
printf "mkdir D_Host_clean\n"
printf "mkdir kraken2_08_output\n"
printf "mkdir bracken_output\n"
printf "\n\n"


printf "conda activate fastqc_v0.12.1"
printf "\n\n"

cat SampleList | while read line; do

	printf "### Sample: "
    printf $line
   	printf "  ### \n"
    
	# Step 1: Quality check (FastQC)
    printf "fastqc -t 16 --memory 10000 "
    printf $pathToFASTQFiles
    printf $line
    printf "_R1_001.fastq.gz "
    printf $pathToFASTQFiles
    printf $line
    printf "_R2_001.fastq.gz "
    printf " -o A_FastQC/"
    printf "\n"

 	printf "\n"
 done;

 printf "conda deactivate"
 printf "\n\n"


printf "conda activate star-fusion_v1.14"
printf "\n\n"

cat SampleList | while read line; do

	printf "### Sample: "
    printf $line
   	printf "  ### \n"

    # Step 2: Trim adapters and low-quality bases (Trimmomatic)
    printf "trimmomatic "
    printf "PE -threads 16 "
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
    printf "ILLUMINACLIP:$ADAPTERS/NexteraPE-PE.fa:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:20 MINLEN:36"
   	printf "\n"

 	printf "\n"
 done;

 printf "conda deactivate"
 printf "\n\n"




printf "conda activate fastqc_v0.12.1"
printf "\n\n"

cat SampleList | while read line; do

	printf "### Sample: "
    printf $line
   	printf "  ### \n"
    
	# Step 3: Quality check on trimmed (FastQC)
	printf "fastqc -t 16 --memory 10000 "
	printf "./B_Trimmomatic/"
	printf $line
	printf "_R1_paired.fastq.gz "
	printf "./B_Trimmomatic/"
	printf $line
	printf "_R2_paired.fastq.gz "
	printf " -o C_FastQC_trimmed/"
	printf "\n"

 	printf "\n"
 done;

 printf "conda deactivate"
 printf "\n\n"



printf "conda polypolish"
printf "\n\n"

cat SampleList | while read line; do

	printf "### Sample: "
    printf $line
   	printf "  ### \n"
    
	# Step 4: Host DNA removal (BWA mapping to bovine genome)
	printf "bwa mem -t 16 /work_2/natanastas/ARENA/Bos_taurus_genome/Bos_taurus.fna "
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

 	printf "\n"
 done;

 printf "conda deactivate"
 printf "\n\n"



printf "conda activate samtools_v1.22.1"
printf "\n\n"

cat SampleList | while read line; do

	printf "### Sample: "
    printf $line
   	printf "  ### \n"
    
	printf "samtools view -@ 16 -bS "
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

	printf "samtools view -@ 16 -b -f 12 -F 256 "
	printf "D_Host_clean/"
	printf $line
	printf ".sam > D_Host_clean/"
	printf $line
	printf ".clean.bam"
	printf "\n"

	printf "samtools sort -n -@ 16 D_Host_clean/"
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

	
#	printf "rm "
#	printf "D_Host_clean/"
#	printf $line
#	printf ".bam"
#	printf "\n"

 	printf "\n"
 done;

 printf "conda deactivate"
 printf "\n\n"


printf "conda activate bracken"
printf "\n\n"

cat SampleList | while read line; do

	printf "### Sample: "
    printf $line
   	printf "  ### \n"
    
	# Step 5: kraken2 - bracken analysis    
	printf "kraken2 --db /work_2/natanastas/ARENA/db/k2_standard_08/"
	printf " --threads 16 --paired --gzip-compressed --confidence 0.1 --minimum-hit-groups 3"
	printf " --report kraken2_08_output/"
	printf $line
	printf ".report"
	printf " --output kraken2_08_output/"
	printf $line
	printf ".out "
	printf " D_Host_clean/"
	printf $line
	printf "_clean_R1.fastq.gz D_Host_clean/"
	printf $line
	printf "_clean_R2.fastq.gz"
    printf "\n"

	printf "bracken -d /work_2/natanastas/ARENA/db/k2_standard_08/"
	printf " -i kraken2_08_output/"
	printf $line
	printf ".report -o bracken_output/"
	printf $line
	printf ".bracken -w bracken_output/"
	printf $line
	printf ".breport -r 150 -l S -t 10"
	printf "\n"

#	printf "rm kraken2_08_output/"
#	printf $line
#	printf ".out"
#	printf "\n"

 	printf "\n"
 done;

printf "combine_bracken_outputs.py --files bracken_output/*.bracken -o abundance_table_species.tsv\n"

 printf "conda deactivate"
 printf "\n\n"
