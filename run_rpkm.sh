#! /bin/bash
#PBS -l nodes=1:ppn=1
#PBS -l mem=1g
#PBS -l walltime=1:00:00 
#PBS -M z.huang@dkfz.de
#PBS -m a
#PBS -j oe

source /home/huangz/scripts_tmp/config.sh

# constant defined by config.sh
# samtools="/ibios/tbi_cluster/11.4/x86_64/bin/samtools-0.1.19"

#sample_dir=$1
# set directory of star results, input without "/"
#htseq_dir="$sample_dir/htseq_count_star"


Rscript $binRPKM $htseqFile $rpkmFile

#Rscript $binRPKM $htseq_dir/htseq_${smID}_no $htseq_dir/rpkm_${smID}_no
#Rscript $binRPKM $htseq_dir/htseq_${smID}_no_rm $htseq_dir/rpkm_${smID}_no_rm
#Rscript $binRPKM $htseq_dir/htseq_${smID}_reverse $htseq_dir/rpkm_${smID}_reverse
#Rscript $binRPKM $htseq_dir/htseq_${smID}_reverse_rm $htseq_dir/rpkm_${smID}_reverse_rm
#Rscript $binRPKM $htseq_dir/htseq_${smID}_yes $htseq_dir/rpkm_${smID}_yes
#Rscript $binRPKM $htseq_dir/htseq_${smID}_yes_rm $htseq_dir/rpkm_${smID}_yes_rm


