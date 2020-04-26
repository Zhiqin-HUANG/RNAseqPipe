#! /bin/bash
#PBS -l nodes=1:ppn=1
#PBS -l mem=300mb
#PBS -l walltime=50:00:00 
#PBS -M z.huang@dkfz.de
#PBS -m a
#PBS -j oe

# module load python to use htseq-cound command 

source /home/huangz/scripts_tmp/config.sh

# constant defined in config.sh
# samtools="/ibios/tbi_cluster/11.4/x86_64/bin/samtools-0.1.19"
# encode_gtf="/icgc/dkfzlsdf/analysis/hipo_017/reference/gencode.v19.annotation_noChr.gtf"

###############################################
###############################################
##### this script requires three input parameters:
# $sample_dir, the sample folder in results' folder
# $rmDup, "yes" or "no" to choose whether duplicates counting or not
# $specificity, "yes", "reverse" or "no".
################################################
################################################

# define temporty files for large intern-sam file
TMP=`mktemp $PBS_SCRATCH_DIR/$PBS_JOBID/XXXXXXXXXX`

#-------Required Parameters--------#
# minQ, minimum quality, htseq-count consider only uniq reads
# so minQ doesn't matter
minQ=1
# counting model in HTseq package, default is 'union'
model="union"
# mode of strand-specific assay ('yes','no' and 'reverse'), default is 'yes'. We count Yes and Reverse together.
# choose feature, e.g. gene or exon
feature="exon"
# choose id
id="gene_id"
# annotaion gtf
echo "Current annotation: $encode_gtf"

# set directory of star results
star_dir="$sample_dir/star"

# if sortByName.bam is not there, exit the program.
sortedBam="${star_dir}/Aligned.out.rg.dupFlag_sortByName.bam"
if [ ! -e "${sortedBam}" ]; then
        echo "${sortedBam} is not found, please check your files... Exit..." >&2
        exit 1
fi

# set directory of htseq count
htseq_dir="$sample_dir/htseq_count_star"
# create folder of htseq_count, if it is not existed.
if [ -d "$htseq_dir" ]; then
        echo "$htseq_dir is already there, please check it..Resutls will be overwritten"
else
        mkdir $htseq_dir
fi

# extract the name of sample folder
smID=`echo $sample_dir | awk '{split($0,arr,"/");print arr[length(arr)]}'`

# choose which strand-specific, rmDup or not.
if [ "$rmDup" == "no" ]; then
	if [ ! -s "${htseq_dir}/htseq_${smID}_${specificity}" ];then
		$samtools view -F 4 $sortedBam | htseq-count -t $feature -i $id -m $model -s $specificity -a $minQ -q -  $encode_gtf > $htseq_dir/htseq_${smID}_${specificity}
		echo "$samtools view -F 4 $sortedBam | htseq-count -t $feature -i $id -m $model -s $specificity -a $minQ -q -  $encode_gtf > $htseq_dir/htseq_${smID}_${specificity}"
	else
		echo "$htseq_dir/htseq_${smID}_${specificity} is already there"
	fi
fi

# to avoid Error: ("Malformed SAM line: MRNM == '*' although flag bit &0x0008 cleared"
# http://seqanswers.com/forums/showthread.php?t=22652
# remove unmapped reads before htseq-count
if [ "${rmDup}" == "yes" ]; then
	if [ ! -s "${htseq_dir}/htseq_${smID}_${specificity}_rm" ];then
		$samtools view -F 1028 $sortedBam | htseq-count -t $feature -i $id -m $model -s $specificity -a $minQ -q -  $encode_gtf > $htseq_dir/htseq_${smID}_${specificity}_rm
		echo "$samtools view -F 1028 $sortedBam | htseq-count -t $feature -i $id -m $model -s $specificity -a $minQ -q -  $encode_gtf > $htseq_dir/htseq_${smID}_${specificity}_rm"
	else
		echo "${htseq_dir}/htseq_${smID}_${specificity}_rm is already there"
	fi
fi

rm $TMP

