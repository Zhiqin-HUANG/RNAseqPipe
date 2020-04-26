#! /bin/bash
#PBS -l nodes=1:ppn=10
#PBS -l mem=36g
#PBS -l walltime=10:00:00 
#PBS -M z.huang@dkfz.de
#PBS -m a
#PBS -j oe

source /home/huangz/scripts_tmp/config.sh

# constant defined by config.sh
# samtools="/ibios/tbi_cluster/11.4/x86_64/bin/samtools-0.1.19"

# max memory per thread
buff=3G
threads=10
#sample_dir=$1
# set directory of star results, input without "/"
star_dir="$sample_dir/star"

# if tophat/all_alignment_fixMate_mark_dupFlag.bam not found, exit the program.
# if sortByName.bam is not there, exit the program.
bamFile=${star_dir}/Aligned.out.rg.dupFlag.bam
bamSorted=${star_dir}/Aligned.out.rg.dupFlag_sortByName.bam
prefix=${star_dir}/Aligned.out.rg.dupFlag_sortByName

if [ ! -e "${bamFile}" ]; then
        echo "${bamFile} is not found, please check your directory... Exit..." >&2
        exit 1
else
        if [ -e "${bamSorted}" ]; then
                echo "${bamSorted} is already there, please check your files... Exit..." >&2
                exit 0
        else
		command="$samtools sort -@ $threads  -n -m $buff  $bamFile $prefix"
		echo $command
		"$samtools" sort -@ $threads  -n -m $buff  $bamFile $prefix
        fi
fi

