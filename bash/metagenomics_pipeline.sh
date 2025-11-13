# ls -la /work/natanastas/Merge/20250127 | awk '{print $9}' | awk -F "_L" '{print $1}' | sort | uniq > SampleList
pathToFASTQFiles="/mnt/new_home/kate_mallou/Karolinska_RNASeq/"

printf "mkdir qualityRaw\n"
printf "source activate star_aligner"
printf "\n\n"

cat SampleList | while read line; do

	printf "### Sample: "
	printf $line
	printf "  ### \n"

	printf "fastqc -t 16 "
	printf $pathToFASTQFiles
	printf $line
	printf "*_R1_*.fastq.gz "
	printf $pathToFASTQFiles
	printf $line
	printf "*_R2_*.fastq.gz "
	printf " -o qualityRaw/"
	printf "\n"

done;

printf "conda deactivate"
printf "\n\n"
printf "rm *.sam"
printf "\n\n"
