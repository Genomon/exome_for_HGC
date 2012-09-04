#!/bin/bash
#$ -S /bin/bash
#$ -cwd
#
#  Copyright Human Genome Center, Institute of Medical Science, the University of Tokyo
#  @since 2012
#

readonly INPUTBAM=$1
readonly OUTPUTDIR=$2
readonly TYPE=$3

source ${CN_ENV}
source ${UTIL}

check_num_args $# 3

echo "${BEDTOOLS}/mergeBed -i ${BAITINFO} > ${OUTPUTDIR}/${TYPE}.bait.bed"
${BEDTOOLS}/mergeBed -i ${BAITINFO} > ${OUTPUTDIR}/${TYPE}.bait.bed
check_error $?

# remove duplicate reads
echo "${SAMTOOLS}/samtools view -F 1024 -b ${INPUTBAM} > ${OUTPUTDIR}/${TYPE}.tmp.bam"
${SAMTOOLS}/samtools view -F 1024 -b ${INPUTBAM} > ${OUTPUTDIR}/${TYPE}.tmp.bam
check_error $?

# generate coverage infomation using Bedtools
echo "${BEDTOOLS}/coverageBed -abam ${OUTPUTDIR}/${TYPE}.tmp.bam -b ${OUTPUTDIR}/${TYPE}.bait.bed -d > ${OUTPUTDIR}/${TYPE}.coverage"
${BEDTOOLS}/coverageBed -abam ${OUTPUTDIR}/${TYPE}.tmp.bam -b ${OUTPUTDIR}/${TYPE}.bait.bed -d > ${OUTPUTDIR}/${TYPE}.coverage
check_error $?

# count the sum of depth for each bait
echo "${PERL} ${COMMAND_CN}/proc_coverage.pl ${OUTPUTDIR}/${TYPE}.coverage > ${OUTPUTDIR}/${TYPE}.count"
${PERL} ${COMMAND_CN}/proc_coverage.pl ${OUTPUTDIR}/${TYPE}.coverage > ${OUTPUTDIR}/${TYPE}.count
check_error $?


rm -f ${OUTPUTDIR}/${TYPE}.bait.bed
rm -f ${OUTPUTDIR}/${TYPE}.tmp.bam
rm -f ${OUTPUTDIR}/${TYPE}.coverage


: <<'#__COMMENT_OUT__'
#__COMMENT_OUT__

