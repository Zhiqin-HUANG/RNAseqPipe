#! /bin/bash

#the required scripts
scriptTmp=/home/huangz/scripts_tmp/hipo059
star_sh=$scriptTmp/run_star.sh
markDup_sh=$scriptTmp/run_markDup.sh
sortByName_sh=$scriptTmp/run_sortByName_star.sh
rseqc_sh=$scriptTmp/run_RSeQC.sh
htseq_sh=$scriptTmp/run_htseq.sh
rseqc2_sh=$scriptTmp/run_RSeQC2.0.sh
binRPKM_TPM=$scriptTmp/bin_RPKM_TPM.R
rpkm_sh=$scriptTmp/run_rpkm.sh
igvTrack_sh=$scriptTmp/run_igvTrack.sh

igvCountsBin=/icgc/dkfzlsdf/analysis/D120/tools/igvtools_custom
chrSize=/icgc/dkfzlsdf/analysis/D120/tools/ucsc/fetchChromSizes.hg19.txt
#chrSize=/icgc/dkfzlsdf/analysis/D120/tools/ucsc/fetchChromSizes.hg19.txt
wigTobw=/icgc/dkfzlsdf/analysis/D120/tools/ucsc/wigToBigWig


# define your log folder
log=/icgc/dkfzlsdf/analysis/hipo/hipo_059/huangz/clusterLog
starLog=$log
markDupLog=$log
sortLog=$log
htseqLog=$log
rseqcLog=$log
rseqc2Log=$log
rpkmLog=$log
igvTrackLog=$log

# tools
samtools="/ibios/tbi_cluster/11.4/x86_64/bin/samtools-0.1.19"
picard=$scriptTmp/picard.sh
#picard=/ibios/tbi_cluster/13.1/x86_64/bin/picard-1.6.1
rseqc2=/icgc/dkfzlsdf/analysis/D120/tools/RNASeQC/GenePatternServer/taskLib/RNASeQC.2.0/RNAseqMetrics.jar
rseqc="/icgc/dkfzlsdf/analysis/D120/tools/RNASeQC/RNA-SeQC_v1.1.7.jar"
#star=/ibios/tbi_cluster/11.4/x86_64/bin/STAR
star=/ibios/tbi_cluster/13.1/x86_64/bin/STAR-2.5

# tempory folder for STAR alignment step ==> picard sorted by coordinate
tmpDir=/icgc/dkfzlsdf/analysis/D120/huangz/tmp/

# Annotation 
# /icgc/dkfzlsdf/analysis/D120/huangz/reference/gencode.v19.annotation.gtf
encode_gtf=/icgc/dkfzlsdf/analysis/D120/huangz/reference/gencode.v19.annotation_noChr.gtf

# reference
#ref=/icgc/dkfzlsdf/analysis/D120/huangz/reference/1K_genome/hs37d5.fa
ref=/icgc/ngs_share/assemblies/hg19_GRCh37_1000genomes/sequence/1KGRef_Phix/hs37d5_PhiX.fa
rRNA=/icgc/dkfzlsdf/analysis/D120/huangz/reference/human_rRNA/human_all_rRNA.fasta
rlist=/icgc/dkfzlsdf/analysis/D120/huangz/reference/rRNA_intervals_MT_gencode19.list
# STAR index 
#genomeDir=/icgc/dkfzlsdf/analysis/D120/huangz/reference/star_gencodeV19_noChr_len101
genomeDir=/icgc/ngs_share/assemblies/hg19_GRCh37_1000genomes/indexes/STAR/STAR_2.5.2b_1KGRef_PhiX_Gencode19_100bp

# additional tag
# platform
rgPL="Hiseq"
# library ID
rgLB="ssRNA"


