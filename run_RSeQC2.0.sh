#! /bin/bash
#PBS -l nodes=1:ppn=1
#PBS -l mem=20g
#PBS -l walltime=30:00:00 
#PBS -M z.huang@dkfz.de
#PBS -m a
#PBS -j oe
source /home/huangz/scripts_tmp/config.sh

###constant defined in config.sh
#check the reference genome fasta, which has the same order as in aligned.bam
#ref="/icgc/dkfzlsdf/analysis/hipo_017/reference/1K_genome/hs37d5.fa"
#encode_gtf="/icgc/dkfzlsdf/analysis/hipo_017/reference/gencode.v19.annotation_noChr.gtf"
#rRNA="/icgc/dkfzlsdf/analysis/hipo_017/reference/human_rRNA/human_all_rRNA.fasta"
#rseqc2="/icgc/dkfzlsdf/analysis/hipo_017/software/GenePatternServer/taskLib/RNASeQC.2.0/RNAseqMetrics.jar"
# library ID
#rgLB="ssRNA"


#Number of top transcripts to use
topNr=1000

smID=`echo $smID_path | awk '{split($1,arr,"\/");print arr[length(arr)]}'`
echo "The sample path: " $smID_path
echo "The sample ID: " $smID
echo "Annotation GTF: $encode_gtf"
echo "Genome reference: $ref"
echo "rRNA reference: $rRNA" 

#rseqcOut=$output/RSeQC_star
rseqcOut=${smID_path}/RSeQC2.0_star
output=${smID_path}/star

touch $output/running_QC_2
#
if [ ! -e "${rseqcOut}/report.html" ];then
	## run RSeQC software, the standard output and error will be deleted by "&> /dev/null"
	echo ">>>> Run RSeQC 2.0 package..."
	echo "java -jar $rseqc2 -o $rseqcOut -s \"$smID\|$output/Aligned.out.rg.dupFlag.bam\|$rgLB\" -r $ref -t $encode_gtf -n $topNr -rRNA $rlist &> /dev/null"
	#java -jar $rseqc2 -o $rseqcOut -s \"$smID\|$output/Aligned.out.rg.dupFlag.bam\|$rgLB\" -r $ref -t $encode_gtf -BWArRNA $rRNA -n $topNr &> /dev/null
	java -jar $rseqc2 -o $rseqcOut -s \"$smID\|$output/Aligned.out.rg.dupFlag.bam\|$rgLB\" -r $ref -t $encode_gtf -n $topNr -rRNA $rlist &> /dev/null
fi

if [ -e "${rseqcOut}/report.html" ];then
        touch $output/finish_QC_2
fi

rm $output/running_QC_2


