printf "mkdir bwa_megares"


cat SampleList | while read line; do


        printf "### Sample: "
        printf $line
        printf "  ### \n"


 	# Step 5: align to AMR
        printf "bwa mem -t 4 /mnt/siarkou_a/groups/siarkou/AMR/megares.fasta "
        printf "./bwa_output/"
        printf $line
        printf "_R1.fastq.gz "
        printf "./bwa_output/"
        printf $line
        printf "_R2.fastq.gz "
        printf " > bwa_megares/"
        printf $line
        printf "_amr.sam"
        printf "\n"

        printf "samtools view -@ 4 -bS "
        printf "bwa_megares/"
        printf $line
        printf "_amr.sam -o "
        printf "bwa_megares/"
        printf $line
        printf "_amr.bam"
        printf "\n"

        printf "samtools sort "
        printf "bwa_megares/"
        printf $line
        printf "_amr.sam -o "
        printf "bwa_megares/"
        printf $line
        printf "_amr.sorted.bam"
        printf "\n"
 
        printf "samtools flagstat "
        printf "bwa_megares/"
        printf $line
        printf "_amr.sorted.bam > "
        printf "bwa_megares/"
        printf $line
        printf "_amr.megares.report.txt"
        printf "\n"

        printf "samtools index "
        printf "./bwa_megares/"
        printf $line
	printf "_amr.sorted.bam"
        printf "\n"


        printf "\n\n"

 done;





