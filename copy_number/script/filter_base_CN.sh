#! /bin/bash
#$ -S /bin/bash
#$ -cwd
#
#  Copyright Human Genome Center, Institute of Medical Science, the University of Tokyo
#  @since 2012
#

readonly NUM=${SGE_TASK_ID}

readonly TYPE_TUM=$1 # usually tumor
readonly TYPE_NOR=$2 # usually normal
readonly ALLELEDIR=$3

source ${CN_ENV}
source ${UTIL}

check_num_args $# 3

# filter candidate of variation between tumor and normal
echo "${PERL} ${COMMAND_CN}/filter_base_CN.pl ${ALLELEDIR}/tmp/temp${NUM}.${TYPE_NOR}.base ${ALLELEDIR}/tmp/temp${NUM}.${TYPE_TUM}.base > ${ALLELEDIR}/tmp/temp${NUM}.${TYPE_TUM}.base.filt"
${PERL} ${COMMAND_CN}/filter_base_CN.pl ${ALLELEDIR}/tmp/temp${NUM}.${TYPE_NOR}.base ${ALLELEDIR}/tmp/temp${NUM}.${TYPE_TUM}.base > ${ALLELEDIR}/tmp/temp${NUM}.${TYPE_TUM}.base.filt
check_error $?


rm -f ${ALLELEDIR}/tmp/temp${NUM}.${TYPE_NOR}.base
rm -f ${ALLELEDIR}/tmp/temp${NUM}.${TYPE_TUM}.base


: <<'#__COMMENT_OUT__'
#__COMMENT_OUT__

