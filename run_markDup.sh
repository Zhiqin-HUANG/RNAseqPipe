#! /bin/bash
#PBS -l nodes=1:ppn=1
#PBS -l mem=20g
#PBS -l walltime=50:00:00 
#PBS -M z.huang@dkfz.de
#PBS -m a
#PBS -j oe
source /home/huangz/scripts_tmp/config.sh

# constant defined by config.sh
# picard="/icgc/dkfzlsdf/analysis/hipo_017/scripts/picard.sh"
# tmpDir="/icgc/dkfzlsdf/analysis/hipo_017/tmp"

######
# This script runs for marking duplicates with picard, creats index
######

starOut=$star_dir

# run picard, preprocessed, mark duplicates and create index, MD5
if [ ! -f "$starOut/Aligned.out.rg.dupFlag.bam" ];then
	echo ">>>> makr duplicates, create index..."
	echo "$picard MarkDuplicates INPUT=$starOut/Aligned.out.rg.bam  OUTPUT=$starOut/Aligned.out.rg.dupFlag.bam METRICS_FILE=$starOut/picard_markDuplicates_metrics CREATE_MD5_FILE=true CREATE_INDEX=true VALIDATION_STRINGENCY=SILENT MAX_RECORDS_IN_RAM=10000000 VERBOSITY=ERROR TMP_DIR=$tmpDir"
	$picard MarkDuplicates INPUT=$starOut/Aligned.out.rg.bam  OUTPUT=$starOut/Aligned.out.rg.dupFlag.bam METRICS_FILE=$starOut/picard_markDuplicates_metrics CREATE_MD5_FILE=true CREATE_INDEX=true VALIDATION_STRINGENCY=SILENT MAX_RECORDS_IN_RAM=10000000 VERBOSITY=ERROR TMP_DIR=$tmpDir

	# rename index file
	echo ">>>> Rename .bai file..."
	mv $starOut/Aligned.out.rg.dupFlag.bai $starOut/Aligned.out.rg.dupFlag.bam.bai
else
	echo ">>>> $starOut/Aligned.out.rg.dupFlag.bam is there"
	exit 0
fi
