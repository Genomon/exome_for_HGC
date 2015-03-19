#! /bin/bash
#$ -S /bin/bash
#$ -cwd

#  Copyright Human Genome Center, Institute of Medical Science, the University of Tokyo
#  @since 2012


SAMPLE_FOLDER=$1
TYPE=$2  # e.g. tumor TAM
TYPE2=$3 # e.g. normal
INPUTPATH=$4
ANNOPATH=$5
SCRIPTDIR=$6
TMPDIR=$7
PYTHON=$8
DEBUG_MODE=$9

source ${SCRIPTDIR}/utility.sh

# sleep 
if [ -z DEBUG_MODE ]; then
  sh ${SCRIPTDIR}/sleep.sh
fi

TYPE_FILENAME=${TYPE}_${TYPE2}
if [ ${TYPE2} = "---" ]; then
  TYPE_FILENAME=${TYPE}
fi

OUTFILE_PREFIX=sum_${SAMPLE_FOLDER}_${TYPE_FILENAME}


CURRDIR=`pwd`
cd ${ANNOPATH}
# 2015.03.18
# echo "./summarize_annovar.pl -buildver hg19 -verdbsnp 131 ${INPUTPATH}/output.${TYPE_FILENAME}.anno humandb/ -outfile ${OUTFILE_PREFIX}"
# ./summarize_annovar.pl -buildver hg19 -verdbsnp 131 -outfile ${OUTFILE_PREFIX} ${INPUTPATH}/output.${TYPE_FILENAME}.anno humandb/
echo "perl table_annovar.pl ${INPUTPATH}/output.${TYPE_FILENAME}.anno humandb/ -buildver hg19 -out ${OUTFILE_PREFIX} -protocol refGene,mce46way,segdup,esp5400_all,1000g2010nov_all,snp131,avsift,ljb_all -operation g,r,r,f,f,f,f,f --otherinfo --csvout"
perl table_annovar.pl ${INPUTPATH}/output.${TYPE_FILENAME}.anno humandb/ -buildver hg19 -out ${OUTFILE_PREFIX} -protocol refGene,mce46way,segdup,esp5400_all,1000g2010nov_all,snp131,avsift,ljb_all -operation g,r,r,f,f,f,f,f --otherinfo --csvout
check_error $?
cd ${CURRDIR}


# 2015.03.18
# echo "cp ${ANNOPATH}/${OUTFILE_PREFIX}.exome_summary.csv ${INPUTPATH}/${OUTFILE_PREFIX}.exome_summary.csv"
# cp ${ANNOPATH}/${OUTFILE_PREFIX}.exome_summary.csv ${INPUTPATH}/${OUTFILE_PREFIX}.exome_summary.csv
# echo "cp ${ANNOPATH}/${OUTFILE_PREFIX}.genome_summary.csv ${INPUTPATH}/${OUTFILE_PREFIX}.genome_summary.csv"
# cp ${ANNOPATH}/${OUTFILE_PREFIX}.genome_summary.csv ${INPUTPATH}/${OUTFILE_PREFIX}.genome_summary.csv
# check_error $?
echo "cp ${ANNOPATH}/${OUTFILE_PREFIX}.hg19_multianno.csv ${INPUTPATH}/${OUTFILE_PREFIX}.hg19_multianno.csv"
cp ${ANNOPATH}/${OUTFILE_PREFIX}.hg19_multianno.csv ${INPUTPATH}/${OUTFILE_PREFIX}.hg19_multianno.csv
check_error $?


# 2015.03.18
# echo "${PYTHON} ${SCRIPTDIR}/csv2tsv.py ${INPUTPATH}/${OUTFILE_PREFIX}.exome_summary.csv ${INPUTPATH}/${OUTFILE_PREFIX}.exome_summary.txt"
# ${PYTHON} ${SCRIPTDIR}/csv2tsv.py ${INPUTPATH}/${OUTFILE_PREFIX}.exome_summary.csv ${INPUTPATH}/${OUTFILE_PREFIX}.exome_summary.txt
# check_error $?
# echo "${PYTHON} ${SCRIPTDIR}/csv2tsv.py ${INPUTPATH}/${OUTFILE_PREFIX}.genome_summary.csv ${INPUTPATH}/${OUTFILE_PREFIX}.genome_summary.txt"
# ${PYTHON} ${SCRIPTDIR}/csv2tsv.py ${INPUTPATH}/${OUTFILE_PREFIX}.genome_summary.csv ${INPUTPATH}/${OUTFILE_PREFIX}.genome_summary.txt
echo "${PYTHON} ${SCRIPTDIR}/csv2tsv.py ${INPUTPATH}/${OUTFILE_PREFIX}.hg19_multianno.csv ${INPUTPATH}/${OUTFILE_PREFIX}.hg19_multianno.txt"
${PYTHON} ${SCRIPTDIR}/csv2tsv.py ${INPUTPATH}/${OUTFILE_PREFIX}.hg19_multianno.csv ${INPUTPATH}/${OUTFILE_PREFIX}.hg19_multianno.txt
check_error $?

if [ ${TYPE2} = "---" ]; then
  # 2015.03.18
  # echo "perl ${SCRIPTDIR}/procSummary.barcode.pl ${INPUTPATH}/${OUTFILE_PREFIX}.exome_summary.txt > ${INPUTPATH}/${OUTFILE_PREFIX}.exome.result.txt"
  # perl ${SCRIPTDIR}/procSummary.barcode.pl ${INPUTPATH}/${OUTFILE_PREFIX}.exome_summary.txt > ${INPUTPATH}/${OUTFILE_PREFIX}.exome.result.txt
  # check_error $?
  # echo "perl ${SCRIPTDIR}/procSummary.barcode.pl ${INPUTPATH}/${OUTFILE_PREFIX}.genome_summary.txt > ${INPUTPATH}/${OUTFILE_PREFIX}.genome.result.txt"
  # perl ${SCRIPTDIR}/procSummary.barcode.pl ${INPUTPATH}/${OUTFILE_PREFIX}.genome_summary.txt > ${INPUTPATH}/${OUTFILE_PREFIX}.genome.result.txt
  echo "perl ${SCRIPTDIR}/procSummary.barcode.pl ${INPUTPATH}/${OUTFILE_PREFIX}.hg19_multianno.txt > ${INPUTPATH}/${OUTFILE_PREFIX}.hg19_multianno.result.txt"
  perl ${SCRIPTDIR}/procSummary.barcode.pl ${INPUTPATH}/${OUTFILE_PREFIX}.hg19_multianno.txt > ${INPUTPATH}/${OUTFILE_PREFIX}.hg19_multianno.result.txt
  check_error $?
else 
  # 2015.03.18
  # echo "perl ${SCRIPTDIR}/procSummary.pl ${INPUTPATH}/${OUTFILE_PREFIX}.exome_summary.txt > ${INPUTPATH}/${OUTFILE_PREFIX}.exome.result.txt"
  # perl ${SCRIPTDIR}/procSummary.pl ${INPUTPATH}/${OUTFILE_PREFIX}.exome_summary.txt > ${INPUTPATH}/${OUTFILE_PREFIX}.exome.result.txt
  # check_error $?
  # echo "perl ${SCRIPTDIR}/procSummary.pl ${INPUTPATH}/${OUTFILE_PREFIX}.genome_summary.txt > ${INPUTPATH}/${OUTFILE_PREFIX}.genome.result.txt"
  # perl ${SCRIPTDIR}/procSummary.pl ${INPUTPATH}/${OUTFILE_PREFIX}.genome_summary.txt > ${INPUTPATH}/${OUTFILE_PREFIX}.genome.result.txt
  echo "perl ${SCRIPTDIR}/procSummary.pl ${INPUTPATH}/${OUTFILE_PREFIX}.hg19_multianno.txt > ${INPUTPATH}/${OUTFILE_PREFIX}.hg19_multianno.result.txt"
  perl ${SCRIPTDIR}/procSummary.pl ${INPUTPATH}/${OUTFILE_PREFIX}.hg19_multianno.txt > ${INPUTPATH}/${OUTFILE_PREFIX}.hg19_multianno.result.txt
  check_error $?
fi

rm ${ANNOPATH}/${OUTFILE_PREFIX}.*
check_error $?
# 2015.03.18
# rm ${INPUTPATH}/${OUTFILE_PREFIX}.exome_summary.csv
# rm ${INPUTPATH}/${OUTFILE_PREFIX}.genome_summary.csv
rm ${INPUTPATH}/${OUTFILE_PREFIX}.hg19_multianno.csv
check_error $?

: <<'#__COMMENT_OUT__'
#__COMMENT_OUT__
