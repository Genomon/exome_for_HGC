#!/bin/bash
#$ -S /bin/bash
#$ -cwd

readonly OUTPUTPATH=$1
readonly TAG=$2

source ${EB_CONFIG}
source ${UTIL}

readonly FILECOUNT=`find ${INTERVAL}/*.interval_list | wc -l`
readonly LOCAL_PERL=/usr/local/bin/perl

echo ${OUTPUTPATH}
check_mkdir ${OUTPUTPATH}

echo -n > ${OUTPUTPATH}/output.txt
echo -n > ${OUTPUTPATH}/output.normal.ins.filt
echo -n > ${OUTPUTPATH}/output.normal.del.filt
for i in `seq 1 1 ${FILECOUNT}`
do
  cat ${OUTPUTPATH}/${i}/output.txt >> ${OUTPUTPATH}/output.txt
  check_error $?
  cat ${OUTPUTPATH}/${i}/tmp/temp.normal.ins.filt >> ${OUTPUTPATH}/output.normal.ins.filt
  check_error $?
  cat ${OUTPUTPATH}/${i}/tmp/temp.normal.del.filt >> ${OUTPUTPATH}/output.normal.del.filt
  check_error $?
done

echo "`date '+%Y-%m-%d %H:%M:%S'`"
echo "perl ${DIR}/subscript/filterCloseIndel.pl ${OUTPUTPATH}/output.txt ${OUTPUTPATH}/output.normal.ins.filt ${OUTPUTPATH}/output.normal.del.filt > ${OUTPUTPATH}/output.txt.filt"
perl ${DIR}/subscript/filterCloseIndel.pl ${OUTPUTPATH}/output.txt ${OUTPUTPATH}/output.normal.ins.filt ${OUTPUTPATH}/output.normal.del.filt > ${OUTPUTPATH}/output.txt.filt
check_error $?

CURRDIR=`pwd`
cd ${ANNOPATH} 
echo "./summarize_annovar.pl -buildver hg19 -verdbsnp 131 -outfile ${TAG} ${OUTPUTPATH}/output.txt.filt humandb/"
./summarize_annovar.pl -buildver hg19 -verdbsnp 131 -outfile ${TAG} ${OUTPUTPATH}/output.txt.filt humandb/
check_error $?
cd ${CURRDIR}

echo "`date '+%Y-%m-%d %H:%M:%S'`"
echo "cp ${ANNOPATH}/${TAG}.exome_summary.csv ${OUTPUTPATH}/${TAG}.exome_summary.csv"
cp ${ANNOPATH}/${TAG}.exome_summary.csv ${OUTPUTPATH}/${TAG}.exome_summary.csv
check_error $?

echo "`date '+%Y-%m-%d %H:%M:%S'`"
echo "cp ${ANNOPATH}/${TAG}.genome_summary.csv ${OUTPUTPATH}/${TAG}.genome_summary.csv"
cp ${ANNOPATH}/${TAG}.genome_summary.csv ${OUTPUTPATH}/${TAG}.genome_summary.csv
check_error $?

echo "`date '+%Y-%m-%d %H:%M:%S'`"
echo "python ${DIR}/subscript/csv2tsv.py ${OUTPUTPATH}/${TAG}.exome_summary.csv ${OUTPUTPATH}/${TAG}.exome_summary.txt"
python ${DIR}/subscript/csv2tsv.py ${OUTPUTPATH}/${TAG}.exome_summary.csv ${OUTPUTPATH}/${TAG}.exome_summary.txt
check_error $?

echo "`date '+%Y-%m-%d %H:%M:%S'`"
echo "python ${DIR}/subscript/csv2tsv.py ${OUTPUTPATH}/${TAG}.genome_summary.csv ${OUTPUTPATH}/${TAG}.genome_summary.txt"
python ${DIR}/subscript/csv2tsv.py ${OUTPUTPATH}/${TAG}.genome_summary.csv ${OUTPUTPATH}/${TAG}.genome_summary.txt
check_error $?

echo "`date '+%Y-%m-%d %H:%M:%S'`"
echo "perl ${DIR}/subscript/procSummary.pl ${OUTPUTPATH}/${TAG}.exome_summary.txt > ${OUTPUTPATH}/${TAG}.exome.result.txt"
perl ${DIR}/subscript/procSummary.pl ${OUTPUTPATH}/${TAG}.exome_summary.txt > ${OUTPUTPATH}/${TAG}.exome.result.txt
check_error $?

echo "`date '+%Y-%m-%d %H:%M:%S'`"
echo "perl ${DIR}/subscript/procSummary.pl ${OUTPUTPATH}/${TAG}.genome_summary.txt > ${OUTPUTPATH}/${TAG}.genome.result.txt"
perl ${DIR}/subscript/procSummary.pl ${OUTPUTPATH}/${TAG}.genome_summary.txt > ${OUTPUTPATH}/${TAG}.genome.result.txt
check_error $?

for num in $(seq 1 ${FILECOUNT})
do
  rm -r ${OUTPUTPATH}/${num}
  check_error $?
done

rm ${ANNOPATH}/${TAG}.*
check_error $?
rm ${OUTPUTPATH}/${TAG}.exome_summary.csv
check_error $?
rm ${OUTPUTPATH}/${TAG}.genome_summary.csv
check_error $?
rm ${OUTPUTPATH}/output.*
check_error $?

: <<'#__COMMENT_OUT__'
#__COMMENT_OUT__

