#!/bin/bash
#$ -S /bin/bash
#$ -cwd
#
#  Copyright Human Genome Center, Institute of Medical Science, the University of Tokyo
#  @since 2012
#

readonly NUM=${SGE_TASK_ID}

readonly INPUTBAM=$1
readonly OUTPUTDIR=$2
readonly TYPE=$3

source ${CN_ENV}
source ${UTIL}

check_num_args $# 3

readonly REGION_A=`head -n1 ${INTERVALDIR}/${NUM}.interval_list | awk '{split($0, ARRAY, "-"); print ARRAY[1]}'`
readonly REGION_B=`tail -n1 ${INTERVALDIR}/${NUM}.interval_list | awk '{split($0, ARRAY, "-"); print ARRAY[2]}'`
readonly REGION="${REGION_A}-${REGION_B}"
echo ${REGION}

# extract .bam for a diveded regions form recal.bam 
# remove reads whose mapping quality is less than 20
echo "${SAMTOOLS}/samtools view -h -q 20 -b ${INPUTBAM} ${REGION} >  ${OUTPUTDIR}/temp${NUM}.${TYPE}.bam"
${SAMTOOLS}/samtools view -h -q 20 -b ${INPUTBAM} ${REGION} >  ${OUTPUTDIR}/temp${NUM}.${TYPE}.bam
check_error $?

# pileup diveded .bam files.
echo "${SAMTOOLS}/samtools mpileup -BQ0 -d10000000 -f ${HG19REF} ${OUTPUTDIR}/temp${NUM}.${TYPE}.bam > ${OUTPUTDIR}/temp${NUM}.${TYPE}.pileup"
${SAMTOOLS}/samtools mpileup -BQ0 -d10000000 -f ${HG19REF} ${OUTPUTDIR}/temp${NUM}.${TYPE}.bam > ${OUTPUTDIR}/temp${NUM}.${TYPE}.pileup
check_error $?

# make count files for mismatches, insertions and deletions
# mismatch count is performed considering bases whose quality is more than 15.
echo "${PERL} ${COMMAND_CN}/pileup2base.pl 15 ${OUTPUTDIR}/temp${NUM}.${TYPE}.pileup ${OUTPUTDIR}/temp${NUM}.${TYPE}.base ${OUTPUTDIR}/temp${NUM}.${TYPE}.ins ${OUTPUTDIR}/temp${NUM}.${TYPE}.del"
${PERL} ${COMMAND_CN}/pileup2base.pl 15 ${OUTPUTDIR}/temp${NUM}.${TYPE}.pileup ${OUTPUTDIR}/temp${NUM}.${TYPE}.base ${OUTPUTDIR}/temp${NUM}.${TYPE}.ins ${OUTPUTDIR}/temp${NUM}.${TYPE}.del
check_error $?


rm -f ${OUTPUTDIR}/temp${NUM}.${TYPE}.bam
rm -f ${OUTPUTDIR}/temp${NUM}.${TYPE}.pileup
rm -f ${OUTPUTDIR}/temp${NUM}.${TYPE}.ins
rm -f ${OUTPUTDIR}/temp${NUM}.${TYPE}.del


: <<'#__COMMENT_OUT__'
#__COMMENT_OUT__

