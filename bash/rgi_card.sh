# ls -la ./ | awk '{print $9}' | awk -F "_R" '{print $1}' | sort | uniq > SampleList
rgi bwt   -1 bwa_output/A_A1-20_S2_L001_clean_R1.fastq.gz   -2 bwa_output/A_A1-20_S2_L001_clean_R2.fastq.gz   
-a kma   -o rgi_output/A_A1-20_S2   --local   --threads 24   --include_other_models   --include_wildcard   --coverage 80



pathToFASTQFiles="./bwa_output/"


printf "mkdir rgi_output\n"
printf "\n\n"


cat SampleList | while read line; do


        printf "### Sample: "
        printf $line
        printf "  ### \n"

		# RGI command
        printf "rgi bwt -1 "
        printf $pathToFASTQFiles
        printf $line
        printf "_clean_R1.fastq.gz -2 "
        printf $pathToFASTQFiles
        printf $line
        printf "_clean_R2.fastq.gz -a kma -o rgi_output/"
        printf $line
        printf " --local --threads 24 --include_other_models --include_wildcard --coverage 80\n"
        printf "\n"
        

        printf "\n\n"

done;


printf "\n\n"
printf "### RGI Analysis Complete ###\n"