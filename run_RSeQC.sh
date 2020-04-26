#! /bin/bash
#PBS -l nodes=1:ppn=1
#PBS -l mem=20g
#PBS -l walltime=30:00:00 
#PBS -M z.huang@dkfz.de
#PBS -m a
#PBS -j oe

source /home/huangz/scripts_tmp/config.sh

# constant defined by config.sh
#check the reference genome fasta, which has the same order as in aligned.bam
#ref="/icgc/dkfzlsdf/analysis/hipo_017/reference/1K_genome/hs37d5.fa"
#encode_gtf="/icgc/dkfzlsdf/analysis/hipo_017/reference/gencode.v19.annotation_noChr.gtf"
#rRNA="/icgc/dkfzlsdf/analysis/hipo_017/reference/human_rRNA/human_all_rRNA.fasta"
#rseqc="/icgc/lsdf/mb/analysis/huang/software/RNA-SeQC_v1.1.7.jar"
# library ID
#rgLB="ssRNA"

smID=`echo $smID_path | awk '{split($1,arr,"\/");print arr[length(arr)]}'`
echo "The sample path: " $smID_path
echo "The sample ID: " $smID
echo "Annotation GTF: $encode_gtf"
echo "Genome reference: $ref"
echo "rRNA reference: $rRNA" 

#rseqcOut=$output/RSeQC_star
rseqcOut=${smID_path}/RSeQC_star
output=${smID_path}/star

touch $output/running_QC
#
if [ ! -e "${rseqcOut}/report.html" ];then
	## run RSeQC software, the standard output and error will be deleted by "&> /dev/null"
	echo ">>>> Run RSeQC package..."
	echo "java -jar $rseqc -o $rseqcOut -s \"$smID\|$output/Aligned.out.rg.dupFlag.bam\|$rgLB\" -r $ref -t $encode_gtf -transcriptDetails -gatkFlags -U ALLOW_SEQ_DICT_INCOMPATIBILITY -BWArRNA $rRNA &> /dev/null"
# exe RSeQC
	java -jar $rseqc -o $rseqcOut -s \"$smID\|$output/Aligned.out.rg.dupFlag.bam\|$rgLB\" -r $ref -t $encode_gtf -transcriptDetails -gatkFlags -U ALLOW_SEQ_DICT_INCOMPATIBILITY -BWArRNA $rRNA &> /dev/null
fi

if [ -e "${rseqcOut}/report.html" ];then
        touch $output/finish_QC
fi

rm $output/running_QC


