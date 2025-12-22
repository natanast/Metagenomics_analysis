# ls -la ./ | awk '{print $9}' | awk -F "_R" '{print $1}' | sort | uniq > SampleList

pathToFASTQFiles="./bwa_output/"



printf "mkdir cassette_output\n"
printf "\n\n"


cat SampleList | while read line; do


        printf "### Sample: "
        printf $line
        printf "  ### \n"

        # align to cassette sequences
        printf "bwa mem -t 4 /mnt/siarkou_a/groups/siarkou/genomes/AJ584652.2.fasta "
        printf "./bwa_output/"
        printf $line
        printf "_clean_R1.fastq.gz "
        printf "./bwa_output/"
        printf $line
        printf "_clean_R2.fastq.gz "
        printf " > cassette_output/"
        printf $line
        printf "_cassette.sam"
        printf "\n"

        printf "samtools view -@ 4 -bS "
        printf "cassette_output/"
        printf $line
        printf "_cassette.sam -o "
        printf "cassette_output/"
        printf $line
        printf "_cassette.bam"
        printf "\n"

        printf "samtools flagstat "
        printf "cassette_output/"
        printf $line
        printf "_cassette.bam > "
        printf "cassette_output/"
        printf $line
        printf "_cassette.report.txt"
        printf "\n"

	printf "samtools view -@ 16 -b -F 4 "
	printf "cassette_output/"
	printf $line
	printf "_cassette.bam -o "
	printf "cassette_output/"
	printf $line
	printf "_cassette_mapped.bam"
	printf "\n"

        printf "samtools sort "
        printf "cassette_output/"
        printf $line
        printf "_cassette_mapped.bam -o "
        printf "cassette_output/"
        printf $line
        printf "_cassette_mapped.sorted.bam"
        printf "\n"

        printf "samtools index -@ 16 "
	printf "cassette_output/"
        printf $line
        printf "_cassette_mapped.sorted.bam "
        printf "\n"

        printf "\n\n"

done;

printf "\n\n"
