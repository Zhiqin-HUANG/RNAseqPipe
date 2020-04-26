
# This script normalize the gene expression based on Gencode version 19 gtf.
# RPKM

# command-line parameters
args <- commandArgs(TRUE)
htseqFile=args[1]
rpkmFile=args[2]

#setwd(outputDir)

if (length(args)!=2){
	stop(">>>>>Usage:  Rscript binRPKM.R htseq_count_file rpkm_output_file
		Note: Full Path")
}

# end without "/"
#htseq_folder="/cb0806/huang/htseq_count_miseq"
# clinical subtype information
#subtypes="/cb0805/huang/clinic_data/subtype_data_dir/subtype_data9_table_new0613_NCT_customer_addBiopsy"
geneLengthTable="/icgc/dkfzlsdf/analysis/hipo/hipo_017/reference/geneLength_exon_v19.tab"
geneLength=read.table(geneLengthTable,header=F)

# matrix for gene count in all files
#cGenes=c()
rpkm=c()

# read htseq count table	
x=read.table(htseqFile,stringsAsFactors=F)
#cGenes=cbind(cGenes,x[,2])

# for rpkm, only considering the total number of mapped reads on genes
sumCount=sum(as.numeric(x[1:(nrow(x)-5),2]))
rpkm_m=merge(geneLength,x[1:(nrow(x)-5),],by="V1")
rpkm_m[,2:3] <- as.numeric(as.matrix(rpkm_m[,2:3]))

#### for rpkm
# C = Number of reads mapped to a gene
# N = Total mapped reads on exon
# L = exon length in base-pairs for a gene
# Equation = RPKM = (10^9 * C)/(N * L)
rpkm=cbind(rpkm,as.matrix(rpkm_m[,3]*10^9/sumCount/rpkm_m[,2]))
	
# sample ID
n=unlist(strsplit(htseqFile,"/"))
sample_ID=n[length(n)]


rpkmOutput=cbind(rpkm_m[,1],round(rpkm[, 1], digits = 2),rpkm_m[,2:3])
colnames(rpkmOutput)=c(sample_ID,"RPKM","Gene_Length","Raw_count")

# output file
write.table(rpkmOutput,file=rpkmFile,row.names=FALSE, quote=FALSE, sep="\t")

