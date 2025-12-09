# ls -la ./ | awk '{print $9}' | awk -F "_R" '{print $1}' | sort | uniq > SampleList

pathToFASTQFiles="./bwa_output/"


printf "mkdir kraken2_16_output\n"
printf "\n\n"


cat SampleList | while read line; do


        printf "### Sample: "
        printf $line
        printf "  ### \n"

	# Kraken2 command
        printf "kraken2 --db /mnt/siarkou_a/groups/siarkou/kraken2_db_standard_16/"
	printf " --threads 32 --paired --gzip-compressed --confidence 0.1 --minimum-hit-groups 3"
	printf " --report kraken2_16_output/"
	printf $line
	printf ".report"
	printf " --output kraken2_16_output/"
	printf $line
	printf ".out "
	printf $pathToFASTQFiles
	printf $line
        printf "_clean_R1.fastq.gz "
        printf $pathToFASTQFiles
        printf $line
        printf "_clean_R2.fastq.gz "
        printf "\n"

        printf "\n\n"

done;


printf "\n\n"
printf "### Kraken2 Analysis Complete ###\n"


#kraken2 --db /mnt/siarkou_a/groups/siarkou/kraken2_db/ --threads 32 --paired --gzip-compressed --confidence 0.1 --minimum-hit-groups 3 --report A_A1-20_S2.report --output A_A1-20_S2.out ./bwa_output/A_A1-20_S2_L001_clean_R1.fastq.gz  ./bwa_output/A_A1-20_S2_L001_clean_R2.fastq.gz

