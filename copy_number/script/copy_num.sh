#! /bin/bash
#
#  Copyright Human Genome Center, Institute of Medical Science, the University of Tokyo
#  @since 2012
#

write_usage() {
  echo ""
  echo "Usage: `basename $0` [options] <in tumor.bam> <in normal.bam> <output directory> <tag> <copynum.env>"
  echo ""
}

readonly INPUTBAM_TUM=$1 # usually tumor
readonly INPUTBAM_NOR=$2 # usually normal
readonly OUTPUTDIR=$3
readonly TAG=$4
cn_env=$5

readonly TYPE_TUM=tumor
readonly TYPE_NOR=normal

readonly DIR=`dirname ${0}`

if [ $# -le 3 -o $# -ge 6 ]; then
  echo "wrong number of arguments"
  write_usage
  exit 1
fi

if [ $# -eq 4 ]; then
  cn_env=${DIR}/copynum.env
fi

if [ $# -eq 3 ]; then
  if [ ! -f ${cn_env} ]; then
    echo "${cn_env} dose not exists"
    write_usage
    exit 1
  fi
fi

source ${cn_env}
source ${UTIL}

is_file_exists ${INPUTBAM_TUM}
if [ $? -ne 0 ]; then 
  write_usage 
  exit $?
fi

is_file_exists ${INPUTBAM_NOR}
if [ $? -ne 0 ]; then 
  write_usage 
  exit $?
fi

readonly TOTALDIR=${OUTPUTDIR}/total
readonly ALLELEDIR=${OUTPUTDIR}/alleleSpecific

check_mkdir ${TOTALDIR}
check_mkdir ${ALLELEDIR}/tmp

readonly QSUB_LOGDIR=${LOGDIR}/${TAG}
check_mkdir ${QSUB_LOGDIR}

readonly LOGSTR=-e\ ${QSUB_LOGDIR}\ -o\ ${QSUB_LOGDIR}
readonly FILECOUNT=`find ${INTERVALDIR}/*.interval_list | wc -l`
echo $FILECOUNT

readonly JOB_CN_TOTAL_TUM=total_depth.${TAG}.${TYPE_TUM}
readonly JOB_CN_TOTAL_NOR=total_depth.${TAG}.${TYPE_NOR}
readonly JOB_CN_BAM2HET_TUM=bam2hetero.${TAG}.${TYPE_TUM}
readonly JOB_CN_BAM2HET_NOR=bam2hetero.${TAG}.${TYPE_NOR}
readonly JOB_CN_FILTER=filter_base.${TAG}.${TYPE_TUM}-${TYPE_NOR}
readonly JOB_CN_AS_COUNT=make_as_count.${TAG}.${TYPE_TUM}-${TYPE_NOR}

echo "qsub -v CN_ENV=${cn_env} -l s_vmem=4G,mem_req=4 -N ${JOB_CN_TOTAL_TUM} ${LOGSTR} ${COMMAND_CN}/total_depth.sh ${INPUTBAM_TUM} ${TOTALDIR} ${TYPE_TUM}"
qsub -v CN_ENV=${cn_env} -l s_vmem=4G,mem_req=4 -N ${JOB_CN_TOTAL_TUM} ${LOGSTR} ${COMMAND_CN}/total_depth.sh ${INPUTBAM_TUM} ${TOTALDIR} ${TYPE_TUM}
echo "qsub -v CN_ENV=${cn_env} -l s_vmem=4G,mem_req=4 -N ${JOB_CN_TOTAL_NOR} ${LOGSTR} ${COMMAND_CN}/total_depth.sh ${INPUTBAM_NOR} ${TOTALDIR} ${TYPE_NOR}"
qsub -v CN_ENV=${cn_env} -l s_vmem=4G,mem_req=4 -N ${JOB_CN_TOTAL_NOR} ${LOGSTR} ${COMMAND_CN}/total_depth.sh ${INPUTBAM_NOR} ${TOTALDIR} ${TYPE_NOR}

echo "qsub -v CN_ENV=${cn_env} -t 1-${FILECOUNT}:1 -l s_vmem=2G,mem_req=2 -N ${JOB_CN_BAM2HET_TUM} ${LOGSTR} ${COMMAND_CN}/bam2hetero.sh ${INPUTBAM_TUM} ${ALLELEDIR}/tmp ${TYPE_TUM}"
qsub -v CN_ENV=${cn_env} -t 1-${FILECOUNT}:1 -l s_vmem=2G,mem_req=2 -N ${JOB_CN_BAM2HET_TUM} ${LOGSTR} ${COMMAND_CN}/bam2hetero.sh ${INPUTBAM_TUM} ${ALLELEDIR}/tmp ${TYPE_TUM}
echo "qsub -v CN_ENV=${cn_env} -t 1-${FILECOUNT}:1 -l s_vmem=2G,mem_req=2 -N ${JOB_CN_BAM2HET_NOR} ${LOGSTR} ${COMMAND_CN}/bam2hetero.sh ${INPUTBAM_NOR} ${ALLELEDIR}/tmp ${TYPE_NOR}"
qsub -v CN_ENV=${cn_env} -t 1-${FILECOUNT}:1 -l s_vmem=2G,mem_req=2 -N ${JOB_CN_BAM2HET_NOR} ${LOGSTR} ${COMMAND_CN}/bam2hetero.sh ${INPUTBAM_NOR} ${ALLELEDIR}/tmp ${TYPE_NOR}

echo "qsub -v CN_ENV=${cn_env} -t 1-${FILECOUNT}:1 -l s_vmem=2G,mem_req=2 -N ${JOB_CN_FILTER} -hold_jid ${JOB_CN_TOTAL_TUM},${JOB_CN_TOTAL_NOR},${JOB_CN_BAM2HET_TUM},${JOB_CN_BAM2HET_NOR} ${LOGSTR} ${COMMAND_CN}/filter_base_CN.sh ${TYPE_TUM} ${TYPE_NOR} ${ALLELEDIR}"
qsub -v CN_ENV=${cn_env} -t 1-${FILECOUNT}:1 -l s_vmem=2G,mem_req=2 -N ${JOB_CN_FILTER} -hold_jid ${JOB_CN_TOTAL_TUM},${JOB_CN_TOTAL_NOR},${JOB_CN_BAM2HET_TUM},${JOB_CN_BAM2HET_NOR} ${LOGSTR} ${COMMAND_CN}/filter_base_CN.sh ${TYPE_TUM} ${TYPE_NOR} ${ALLELEDIR}

echo "qsub -v CN_ENV=${cn_env} -l s_vmem=4G,mem_req=4 -N ${JOB_CN_AS_COUNT} -hold_jid ${JOB_CN_FILTER} ${LOGSTR} ${COMMAND_CN}/make_as_count.sh ${TAG} ${TYPE_TUM} ${TYPE_NOR} ${FILECOUNT} ${OUTPUTDIR} ${TOTALDIR} ${ALLELEDIR}"
qsub -v CN_ENV=${cn_env} -l s_vmem=4G,mem_req=4 -N ${JOB_CN_AS_COUNT} -hold_jid ${JOB_CN_FILTER} ${LOGSTR} ${COMMAND_CN}/make_as_count.sh ${TAG} ${TYPE_TUM} ${TYPE_NOR} ${FILECOUNT} ${OUTPUTDIR} ${TOTALDIR} ${ALLELEDIR}

: <<'#__COMMENT_OUT__'
#__COMMENT_OUT__

