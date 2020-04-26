#! /bin/bash
source /home/huangz/scripts_clusters/main_STAR_RNASeQC_HTseq/config.sh

# usage message for users
USAGE="[ Usage: `basename $0` rna_rawData_dir results_per_pid_path
>>>> Note: path without \"/\" end"
# output usage, if input parameters not fittable
if [ $# -ne 2 ]; then
    echo "$USAGE" >&2
    exit 1
fi

rnaLink=$1
resultPath=$2

index=1 # set initial value
for filename in `ls $rnaLink | sort`
do
	if [ "$index" -eq 1 ];then
		first=$filename
		index=$((index + 1))
	else
		second=$filename
		# based on standar name scheme of breast cancer patients
		# this ID have to be the same as in run_star.sh
		splitFirst=`echo "${first//-/_}" | awk 'BEGIN{OFS="_"} {split($0,arr,"_");print arr[1],arr[2],arr[3],arr[4]}'`
		splitSecond=`echo "${second//-/_}" | awk 'BEGIN{OFS="_"} {split($0,arr,"_");print arr[1],arr[2],arr[3],arr[4]}'`
		f1=$rnaLink/$splitFirst
		f2=$rnaLink/$splitSecond
		if [ "$splitFirst" == "$splitSecond" ];then
			pid=$resultPath/$splitFirst
			sampleID=$splitFirst
			if [ ! -d "$pid" ];then

				star_run=`qsub -o $starLog -N ${sampleID}_star -v leftReads=$rnaLink/$first,rightReads=$rnaLink/$second,results_path=$resultPath $star_sh`	

				starFolder=$pid/star

				markDup_run=`qsub -o $markDupLog -W depend=afterok:${star_run} -N ${sampleID}_markDup -v star_dir=$starFolder $markDup_sh`

				rseqc_run=`qsub -o $rseqcLog -W depend=afterok:${markDup_run} -N ${sampleID}_RSeQC -v smID_path="$pid" $rseqc_sh`
	
				rseqc2_run=`qsub -o $rseqc2Log -W depend=afterok:${markDup_run} -N ${sampleID}_RSeQC2 -v smID_path="$pid" $rseqc2_sh`

				sortByName_run=`qsub -o $sortLog -W depend=afterok:${markDup_run} -N ${sampleID}_sortByName -v sample_dir="$pid" $sortByName_sh`
				
				htseq_run1=`qsub -o $htseqLog -W depend=afterok:${sortByName_run} -N ${sampleID}_htseq_rmF -v sample_dir="$pid",rmDup=yes,specificity=yes $htseq_sh`
				htseq_run2=`qsub -o $htseqLog -W depend=afterok:${sortByName_run} -N ${sampleID}_htseq_rmR -v sample_dir="$pid",rmDup=yes,specificity=reverse $htseq_sh`
				htseq_run3=`qsub -o $htseqLog -W depend=afterok:${sortByName_run} -N ${sampleID}_htseq_rmN -v sample_dir="$pid",rmDup=yes,specificity=no $htseq_sh`
				htseq_run4=`qsub -o $htseqLog -W depend=afterok:${sortByName_run} -N ${sampleID}_htseq_F -v sample_dir="$pid",rmDup=no,specificity=yes $htseq_sh`
				htseq_run5=`qsub -o $htseqLog -W depend=afterok:${sortByName_run} -N ${sampleID}_htseq_R -v sample_dir="$pid",rmDup=no,specificity=reverse $htseq_sh`
				htseq_run6=`qsub -o $htseqLog -W depend=afterok:${sortByName_run} -N ${sampleID}_htseq_N -v sample_dir="$pid",rmDup=no,specificity=no $htseq_sh`

				echo "Running $pid"
			#else
			#	echo "$pid will not be processed"
			fi
		fi
		index=1 #reset
	fi		
done

