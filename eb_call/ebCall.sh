#!/bin/bash

write_usage() {
  echo ""
  echo "Usage: `basename $0` <path to the target tumor bam file> <path to the target normal bam file> <path to the output directory> <path to the text file of the list for normal reference samples> [<path to the config.sh>]"
  echo ""
}

# exec > >(tee ${OUTPUTPATH}/tmp/command.log)

INPUTBAM_TUM=$1
INPUTBAM_NOR=$2
OUTPUTPATH=$3
REFERENCELIST=$4
TAG=$5
config=$6

readonly DIR=`dirname ${0}`

if [ $# -le 4 -o $# -ge 7 ]; then
  echo "wrong number of arguments"
  write_usage
  exit 1
fi

if [ $# -eq 5 ]; then
  config=${DIR}/config.sh
fi

if [ $# -eq 6 ]; then
  if [ ! -f ${config} ]; then
    echo "${config} dose not exists"
    write_usage
    exit 1
  fi
fi

readonly ABS_DIR=`echo $(cd ${DIR} && pwd)`
readonly ABS_CONFIG=`echo $(cd $(dirname ${config}) && pwd)/$(basename ${config})`
readonly ABS_REFERENCELIST=`echo $(cd $(dirname ${REFERENCELIST}) && pwd)/$(basename ${REFERENCELIST})`

source ${ABS_CONFIG}
source ${DIR}/utility.sh

check_file_exists ${INPUTBAM_TUM}
check_file_exists ${INPUTBAM_NOR}
check_file_exists ${ABS_REFERENCELIST}

check_mkdir ${OUTPUTPATH}/tmp
readonly ABS_OUTPUTPATH=`echo $(cd ${OUTPUTPATH} && pwd)`

readonly CURLOGDIR=${LOGDIR}/${TAG}
check_mkdir ${CURLOGDIR}
readonly LOGSTR=-e\ ${CURLOGDIR}\ -o\ ${CURLOGDIR}

readonly FILECOUNT=`find ${INTERVAL}/*.interval_list | wc -l`

readonly JOB_EB_MAIN=ebCallMain.${TAG}
readonly JOB_EB_GTHR=ebCallGather.${TAG}

echo "qsub -v EB_CONFIG=${ABS_CONFIG} -v UTIL=${DIR}/utility.sh -v DIR=${ABS_DIR} -t 1-${FILECOUNT}:1 -l s_vmem=4G,mem_req=4 -N ${JOB_EB_MAIN} ${LOGSTR} ${DIR}/subscript/ebCallMain.sh ${INPUTBAM_TUM} ${INPUTBAM_NOR} ${ABS_OUTPUTPATH} ${ABS_REFERENCELIST}"
qsub -v EB_CONFIG=${ABS_CONFIG} -v UTIL=${DIR}/utility.sh -v DIR=${ABS_DIR} -t 1-${FILECOUNT}:1 -l s_vmem=4G,mem_req=4 -N ${JOB_EB_MAIN} ${LOGSTR} ${DIR}/subscript/ebCallMain.sh ${INPUTBAM_TUM} ${INPUTBAM_NOR} ${ABS_OUTPUTPATH} ${ABS_REFERENCELIST}

echo "qsub -v EB_CONFIG=${ABS_CONFIG} -v UTIL=${DIR}/utility.sh -v DIR=${ABS_DIR} -hold_jid ${JOB_EB_MAIN} -l s_vmem=8G,mem_req=8 -N ${JOB_EB_GTHR} ${LOGSTR} ${DIR}/subscript/ebCallGather.sh ${ABS_OUTPUTPATH} ${TAG}"
qsub -v EB_CONFIG=${ABS_CONFIG} -v UTIL=${DIR}/utility.sh -v DIR=${ABS_DIR} -hold_jid ${JOB_EB_MAIN} -l s_vmem=8G,mem_req=8 -N ${JOB_EB_GTHR} ${LOGSTR} ${DIR}/subscript/ebCallGather.sh ${ABS_OUTPUTPATH} ${TAG} 

