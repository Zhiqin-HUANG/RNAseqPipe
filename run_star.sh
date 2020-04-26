#! /bin/bash
#PBS -l nodes=1:ppn=15
#PBS -l mem=48g
#PBS -l walltime=35:00:00 
#PBS -M z.huang@dkfz.de
#PBS -m a
#PBS -j oe
source /home/huangz/scripts_tmp/config.sh

# constant defined by config.sh
#star="/ibios/tbi_cluster/11.4/x86_64/bin/STAR"
#rseqc="/icgc/lsdf/mb/analysis/huang/software/RNA-SeQC_v1.1.7.jar"
#check the reference genome fasta, which has the same order as in aligned.bam
#ref="/icgc/dkfzlsdf/analysis/hipo_017/reference/1K_genome/hs37d5.fa"
#encode_gtf="/icgc/dkfzlsdf/analysis/hipo_017/reference/gencode.v19.annotation_noChr.gtf"
#picard="/icgc/dkfzlsdf/analysis/hipo_017/scripts/picard.sh"
#rRNA="/icgc/dkfzlsdf/analysis/hipo_017/reference/human_rRNA/human_all_rRNA.fasta"
#genomeDir="/icgc/dkfzlsdf/analysis/hipo_017/reference/star_gencodeV19_noChr_len101"
# platform
#rgPL="Hiseq"
# library ID
#rgLB="ssRNA"


## output folder
# results is located in folder without "/" end. Per sample results will be generated in result_path.
#results="/icgc/dkfzlsdf/analysis/hipo_016/results_per_pid"
results=$results_path

#-----parsing parameters----#
#----------Begin------------#
# left reads, if > 1 files, combined with ','
# e.g. left_01_R1,letf_02_R1 right_01_R2,right_02_R2
read1=$leftReads
# right reads, same as left reads, the order must be corresponding.
read2=$rightReads

echo "input rawData: " $read1 $read2

#-----extract sample ID and read group ID-----#
# 1. extract single fule file name
f_name=`echo $read1 | awk '{split($0,array,","); print array[1]}'`
# 2. extract only file name without path
bn=$(basename ${f_name[0]})
# replace "_" with "-"
base=${bn//_/-}
# 3. extract sample ID, splited by "-"
IFS="-"
arr=($base)
smID=${arr[0]}_${arr[1]}_${arr[2]}_${arr[3]}
# 4. extract read group ID
rgID=${arr[0]}_${arr[2]}_${arr[3]}
#---extract flow cell ID and barcode as platform unit---#
title=`gunzip -c "$f_name" | head -n 1`
IFS=":"
arr2=($title)
lenTitle=`expr ${#arr2[@]} - 1`
barcode=`echo ${arr2[2]}_${arr2[${lenTitle}]} | sed 's/\s//g'`

#----------End-------------#
#==========================#

#----create ouput dir for the sample-----#
#--if it is existed, do nothing and exit--#
#--------Begin-------#
# define the output name
output="$results/$smID"
if [ -d "$output" ];then
        echo ">>>> Warning: $output is already there. Please check it..." >&2
else
        mkdir $output
fi

# for star mapping preparation
cd $output

#--------End---------#

#### make star output folder 
# Each STAR run should be made from a fresh working directory. All the output files are stored in the working
# directory. The output files will be overwritten without a warning every time you run STAR.
# results is located in folder without "/" end:
starOut=$output/star
if [ -d "$starOut" ];then
#       echo ">>>> Warning: $starOut is already there. " >&2
	echo ">>>> Warning: $starOut is already there."
        #exit 1
else
        mkdir $starOut
fi

#-----------CHECK-----------#
# check following parameters before running
#check the reference genome fasta, which has the same order as in aligned.bam
#ref="/icgc/dkfzlsdf/analysis/hipo_017/reference/1K_genome/hs37d5.fa"
buffer="/ibios/tbi_cluster/11.4/x86_64/bin/mbuffer"
# htseq-count script, Server is updated
# htseqCount="/icgc/lsdf/mb/analysis/huang/software/htseq-count.py"
# number of threads
p=10
# shared memory strategy
gLoad=LoadAndRemove
# number of mismatches by default is 10.
mis=2
# number of minimum matched basese, default 0.
minBM=0
# min intron size, default to 21
intronMin=21
# SAM attributes, --outSAMattributes
attribute=Standard

echo ">>> Annotation GTF: $encode_gtf"
echo ">>> STAR Index: $genomeDir"
echo ">>> Genome reference: $ref"
echo ">>> rRNA reference: $rRNA"

cd $starOut

if [ ! -s $starOut/Aligned.out.rg.bam ];then
	$star --runMode alignReads --genomeDir $genomeDir --alignIntronMin $intronMin --outFilterMatchNmin $minBM --readFilesIn $read1 $read2 --readFilesCommand zcat --outFilterMismatchNmax $mis --runThreadN $p genomeLoad $gLoad --limitGenomeGenerateRAM 31000000000 --limitIObufferSize 150000000 --outSAMattributes $attribute --outFilterIntronMotifs RemoveNoncanonical --outSAMunmapped Within --outStd SAM | $picard AddOrReplaceReadGroups TMP_DIR=$tmpDir INPUT=/dev/stdin OUTPUT=$starOut/Aligned.out.rg.bam RGID=$rgID RGSM=$smID RGLB=$rgLB RGPU=$barcode RGPL=$rgPL VALIDATION_STRINGENCY=SILENT VERBOSITY=ERROR SORT_ORDER=coordinate MAX_RECORDS_IN_RAM=8000000
	echo "$star --runMode alignReads --genomeDir $genomeDir --alignIntronMin $intronMin --outFilterMatchNmin $minBM --readFilesIn $read1 $read2 --readFilesCommand zcat --outFilterMismatchNmax $mis --runThreadN $p genomeLoad $gLoad --limitGenomeGenerateRAM 31000000000 --limitIObufferSize 150000000 --outSAMattributes $attribute --outFilterIntronMotifs RemoveNoncanonical --outSAMunmapped Within --outStd SAM | $picard AddOrReplaceReadGroups TMP_DIR=$tmpDir INPUT=/dev/stdin OUTPUT=$starOut/Aligned.out.rg.bam RGID=$rgID RGSM=$smID RGLB=$rgLB RGPU=$barcode RGPL=$rgPL VALIDATION_STRINGENCY=SILENT VERBOSITY=ERROR SORT_ORDER=coordinate MAX_RECORDS_IN_RAM=8000000"
fi


# check whether the output file exists or empty
if [ -s $starOut/Aligned.out.rg.bam ];then
        touch $starOut/finish_star
fi






# -limitIObufferSize, max available buffers size (bytes) for input/output, per thread
# --outFilterIntronMotifs , RemoveNoncanonical or RemoveNoncanonicalUnannotated. Or default
##### Run STAR #####
#$star --runMode alignReads --genomeDir $genomeDir --alignIntronMin $intronMin --outFilterMatchNmin $minBM --readFilesIn $read1 $read2 --readFilesCommand zcat --outFilterMismatchNmax $mis --runThreadN $p genomeLoad $gLoad --limitGenomeGenerateRAM 31000000000 --limitIObufferSize 150000000 --outSAMattributes $attribute --outFilterIntronMotifs RemoveNoncanonical --outSAMunmapped Within --outStd SAM | $buffer -m 3G -q | samtools view -S -b - > $starOut/Aligned.out.bam
#$star --runMode alignReads --genomeDir $genomeDir --alignIntronMin $intronMin --outFilterMatchNmin $minBM --readFilesIn $read1 $read2 --readFilesCommand zcat --outFilterMismatchNmax $mis --runThreadN $p genomeLoad $gLoad --limitGenomeGenerateRAM 31000000000 --limitIObufferSize 150000000 --outSAMattributes $attribute --outFilterIntronMotifs RemoveNoncanonical --outSAMunmapped Within --outStd SAM | $picard AddOrReplaceReadGroups TMP_DIR=$tmpDir INPUT=/dev/stdin OUTPUT=$starOut/Aligned.out.rg.bam RGID=$rgID RGSM=$smID RGLB=$rgLB RGPU=$barcode RGPL=$rgPL VALIDATION_STRINGENCY=SILENT VERBOSITY=ERROR SORT_ORDER=coordinate MAX_RECORDS_IN_RAM=8000000
#$star --runMode alignReads --genomeDir $genomeDir --alignIntronMin $intronMin --outFilterMatchNmin $minBM --readFilesIn $read1 $read2 --readFilesCommand zcat --outFilterMismatchNmax $mis --runThreadN $p genomeLoad $gLoad --limitGenomeGenerateRAM 31000000000 --limitIObufferSize 150000000 --outSAMattributes $attribute --outFilterIntronMotifs RemoveNoncanonical --outSAMunmapped Within --outStd SAM | $picard AddOrReplaceReadGroups TMP_DIR=$tmpDir INPUT=/dev/stdin OUTPUT=/dev/stdout RGID=$rgID RGSM=$smID RGLB=$rgLB RGPU=$barcode RGPL=$rgPL VALIDATION_STRINGENCY=SILENT VERBOSITY=ERROR SORT_ORDER=coordinate MAX_RECORDS_IN_RAM=6000000 > $starOut/Aligned.out.rg.bam



#command1="$star --runMode alignReads --genomeDir $genomeDir --alignIntronMin $intronMin --outFilterMatchNmin $minBM --readFilesIn $read1 $read2 --readFilesCommand zcat --outFilterMismatchNmax $mis --runThreadN $p genomeLoad $gLoad --limitGenomeGenerateRAM 31000000000 --limitIObufferSize 150000000 --outSAMattributes $attribute --outFilterIntronMotifs RemoveNoncanonical --outSAMunmapped Within --outStd SAM | samtools view -S -b - > $starOut/Aligned.out.bam"
#command1="$star --runMode alignReads --genomeDir $genomeDir --alignIntronMin $intronMin --outFilterMatchNmin $minBM --readFilesIn $read1 $read2 --readFilesCommand zcat --outFilterMismatchNmax $mis --runThreadN $p genomeLoad $gLoad --limitGenomeGenerateRAM 31000000000 --limitIObufferSize 150000000 --outSAMattributes $attribute --outFilterIntronMotifs RemoveNoncanonical --outSAMunmapped Within --outStd SAM | $picard AddOrReplaceReadGroups TMP_DIR=$tmpDir INPUT=/dev/stdin OUTPUT=$starOut/Aligned.out.rg.bam RGID=$rgID RGSM=$smID RGLB=$rgLB RGPU=$barcode RGPL=$rgPL VALIDATION_STRINGENCY=SILENT VERBOSITY=ERROR SORT_ORDER=coordinate MAX_RECORDS_IN_RAM=8000000"
#command1="$star --runMode alignReads --genomeDir $genomeDir --alignIntronMin $intronMin --outFilterMatchNmin $minBM --readFilesIn $read1 $read2 --readFilesCommand zcat --outFilterMismatchNmax $mis --runThreadN $p genomeLoad $gLoad --limitGenomeGenerateRAM 31000000000 --limitIObufferSize 150000000 --outSAMattributes $attribute --outFilterIntronMotifs RemoveNoncanonical --outSAMunmapped Within --outStd SAM | $picard AddOrReplaceReadGroups TMP_DIR=$tmpDir INPUT=/dev/stdin OUTPUT=/dev/stdout RGID=$rgID RGSM=$smID RGLB=$rgLB RGPU=$barcode RGPL=$rgPL VALIDATION_STRINGENCY=SILENT VERBOSITY=ERROR SORT_ORDER=coordinate MAX_RECORDS_IN_RAM=6000000 > $starOut/Aligned.out.rg.bam"
#echo "$command1"


<<comment_huang
#-----parsing parameters for RSeQC----#
#----------Begin------------#
# platform
rgPL="Hiseq"
# library ID
rgLB="trueSeq"
#-----extract sample ID and read group ID-----#
# 1. extract only file name without path
bn=$(basename "${read1}")
# replace "_" with "-"
base=${bn//_/-}
# 2. extract sample ID, splited by "-"
IFS="-"
arr=($base)
smID=${arr[0]}
# 3. extract read group ID
rgID=${arr[0]}_${arr[1]}

#---extract 'flow cell ID and barcode' as platform unit---#
# barcode may not be there
# do remove all space, Jan 22,2015
title=`gunzip -c "${read1}" | head -n 1`
barcode=`echo $title | awk '{split($0,a,":");print a[3]}' | sed 's/\s//g'`
#title=`head -n 1 "${read1}"`
#IFS=":"
#arr2=($title)
#lenTitle=`expr ${#arr2[@]} - 1`
#barcode=`echo ${arr2[2]}_${arr2[${lenTitle}]} | sed 's/\s//g'`
#----------End-------------#
#==========================#

# define a temporty file for large inter-sam file
# tmpDir="/cb0806/huang/tmp/"

if [ ! -e "${starOut}/Aligned.out.sam" ];then
	echo "${starOut}/Aligned.out.sam doesn't exist there, program exits..."
	exit 1
fi

output=$starOut

# add read group information, sorted by coordinate, output bam
echo ">>>> Add read group information, sorted by coordinate, output .bam"
echo "$picard AddOrReplaceReadGroups TMP_DIR=$tmpDir INPUT=$output/Aligned.out.sam OUTPUT=$output/Aligned.out.rg.sam RGID=$rgID RGSM=$smID RGLB=$rgLB RGPU=$barcode RGPL=$rgPL VALIDATION_STRINGENCY=SILENT VERBOSITY=ERROR SORT_ORDER=coordinate"
$picard AddOrReplaceReadGroups TMP_DIR=$tmpDir INPUT=$output/Aligned.out.sam OUTPUT=$output/Aligned.out.rg.sam RGID=$rgID RGSM=$smID RGLB=$rgLB RGPU=$barcode RGPL=$rgPL VALIDATION_STRINGENCY=SILENT VERBOSITY=ERROR SORT_ORDER=coordinate MAX_RECORDS_IN_RAM=3000000
# TMP_DIR=$tmpDir

# conver sam file to bam
echo "samtools view -b -S $output/Aligned.out.rg.sam -o $output/Aligned.out.rg.bam"
samtools view -b -S $output/Aligned.out.rg.sam -o $output/Aligned.out.rg.bam

# run picard, preprocessed, mark duplicates and create index, MD5
echo ">>>> makr duplicates, create index..."
$picard MarkDuplicates INPUT=$output/Aligned.out.rg.bam  OUTPUT=$output/Aligned.out.rg.dupFlag.bam METRICS_FILE=$output/picard_markDuplicates_metrics CREATE_MD5_FILE=true CREATE_INDEX=true VALIDATION_STRINGENCY=SILENT MAX_RECORDS_IN_RAM=3000000 VERBOSITY=ERROR TMP_DIR=$tmpDir

# rename index file
echo ">>>> Rename .bai file..."
mv $output/Aligned.out.rg.dupFlag.bai $output/Aligned.out.rg.dupFlag.bam.bai

rseqcOut=$output/RSeQC_star
#
## run RSeQC software, the standard output and error will be deleted by "&> /dev/null"
echo ">>>> Run RSeQC package..."
echo "java -jar $rseqc -o $rseqcOut -s \"$smID\|$output/Aligned.out.rg.dupFlag.bam\|$rgLB\" -r $ref -t $encode_gtf -transcriptDetails -gatkFlags -U ALLOW_SEQ_DICT_INCOMPATIBILITY -BWArRNA $rRNA &> /dev/null"
# exe RSeQC
java -jar $rseqc -o $rseqcOut -s \"$smID\|$output/Aligned.out.rg.dupFlag.bam\|$rgLB\" -r $ref -t $encode_gtf -transcriptDetails -gatkFlags -U ALLOW_SEQ_DICT_INCOMPATIBILITY -BWArRNA $rRNA 

#&> /dev/null
comment_huang


