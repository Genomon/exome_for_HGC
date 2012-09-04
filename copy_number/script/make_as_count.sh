#! /bin/bash
#$ -S /bin/bash
#$ -cwd
#
#  Copyright Human Genome Center, Institute of Medical Science, the University of Tokyo
#  @since 2012
#


readonly TAG=$1
readonly TYPE_TUM=$2 # usually tumor
readonly TYPE_NOR=$3 # usually normal
readonly FILECOUNT=$4
readonly OUTPUTDIR=$5
readonly TOTALDIR=$6
readonly ALLELEDIR=$7

source ${CN_ENV}
source ${UTIL}

check_num_args $# 7

# filter candidate of variation between tumor and normal
echo -n > ${ALLELEDIR}/${TYPE_TUM}.hetero.txt
for i in `seq 1 1 ${FILECOUNT}`
do
    echo "cat ${ALLELEDIR}/tmp/temp${i}.${TYPE_TUM}.base.filt >> ${ALLELEDIR}/${TYPE_TUM}.hetero.txt"
    cat ${ALLELEDIR}/tmp/temp${i}.${TYPE_TUM}.base.filt >> ${ALLELEDIR}/${TYPE_TUM}.hetero.txt
    check_error $?
done


echo "${BEDTOOLS}/fastaFromBed -fi ${HG19REF} -bed ${TOTALDIR}/${TYPE_NOR}.count -fo ${OUTPUTDIR}/${TAG}.${TYPE_NOR}.fa -tab"
${BEDTOOLS}/fastaFromBed -fi ${HG19REF} -bed ${TOTALDIR}/${TYPE_NOR}.count -fo ${OUTPUTDIR}/${TAG}.${TYPE_NOR}.fa -tab
check_error $?

echo "${PERL} ${COMMAND_CN}/hetero2abnum2.pl ${ALLELEDIR}/${TYPE_TUM}.hetero.txt > ${OUTPUTDIR}/${TAG}.${TYPE_TUM}.as_count"
${PERL} ${COMMAND_CN}/hetero2abnum2.pl ${ALLELEDIR}/${TYPE_TUM}.hetero.txt > ${OUTPUTDIR}/${TAG}.${TYPE_TUM}.as_count
check_error $?

echo "${BEDTOOLS}/intersectBed -a ${TOTALDIR}/${TYPE_NOR}.count -b ${OUTPUTDIR}/${TAG}.${TYPE_TUM}.as_count -wa -wb > ${OUTPUTDIR}/${TAG}.${TYPE_TUM}.as_count.bait.tmp"
${BEDTOOLS}/intersectBed -a ${TOTALDIR}/${TYPE_NOR}.count -b ${OUTPUTDIR}/${TAG}.${TYPE_TUM}.as_count -wa -wb > ${OUTPUTDIR}/${TAG}.${TYPE_TUM}.as_count.bait.tmp
check_error $?

echo "${R} --vanilla --slave --args ${OUTPUTDIR}/${TAG}.${TYPE_TUM}.as_count.bait.tmp ${OUTPUTDIR}/${TAG}.${TYPE_TUM}.as_count.bait < ${COMMAND_CN}/get_bait_wise_as_count.R"
${R} --vanilla --slave --args ${OUTPUTDIR}/${TAG}.${TYPE_TUM}.as_count.bait.tmp ${OUTPUTDIR}/${TAG}.${TYPE_TUM}.as_count.bait < ${COMMAND_CN}/get_bait_wise_as_count.R
check_error $?

echo "${PERL} ${COMMAND_CN}/makeHMMinput2.pl ${OUTPUTDIR}/${TAG}.${TYPE_NOR}.fa ${OUTPUTDIR}/${TAG}.${TYPE_TUM}.as_count.bait ${TOTALDIR}/${TYPE_NOR}.count ${TOTALDIR}/${TYPE_TUM}.count > ${OUTPUTDIR}/${TAG}.${TYPE_TUM}.shmmg"
${PERL} ${COMMAND_CN}/makeHMMinput2.pl ${OUTPUTDIR}/${TAG}.${TYPE_NOR}.fa ${OUTPUTDIR}/${TAG}.${TYPE_TUM}.as_count.bait ${TOTALDIR}/${TYPE_NOR}.count ${TOTALDIR}/${TYPE_TUM}.count > ${OUTPUTDIR}/${TAG}.${TYPE_TUM}.shmmg
check_error $?

echo "${R} --vanilla --slave --args ${OUTPUTDIR}/${TAG}.${TYPE_TUM} < ${COMMAND_CN}/CBS.R"
${R} --vanilla --slave --args ${OUTPUTDIR}/${TAG}.${TYPE_TUM} < ${COMMAND_CN}/CBS.R
check_error $?

rm -f ${ALLELEDIR}/tmp/temp*.${TYPE_TUM}.base.filt
rm -f ${OUTPUTDIR}/${TAG}.${TYPE_TUM}.as_count.bait.tmp


: <<'#__COMMENT_OUT__'
#__COMMENT_OUT__

