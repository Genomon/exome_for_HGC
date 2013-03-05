# path to the reference genome
PATH_TO_REF=${HOME}/exome/ref/hg19/hg19.fasta

# path to samtools
PATH_TO_SAMTOOLS=${HOME}/exome/bin/samtools-0.1.18

# path to R
PATH_TO_R=/usr/local/bin

# mapping quality threshould
TH_MAPPING_QUAL=30

# base quality threshould
TH_BASE_QUAL=15

# mapping quality threshould
TH_MAPPING_QUAL_REF=30

# base quality threshould
TH_BASE_QUAL_REF=15

# minimum depth in tumor
MIN_TUMOR_DEPTH=8

# minimum depth in normal 
MIN_NORMAL_DEPTH=8

# minimum number of variant reads in tumor
MIN_TUMOR_VARIANT_READ=4

# minimum amount of tumor allele frequency
MIN_TUMOR_ALLELE_FREQ=0.08

# maximum amount of normal allele frequency
MAX_NORMAL_ALLELE_FREQ=0.1

# minimum value for the minus logarithm of p-value
MIN_MINUS_LOG10_PV=3

# interval list for multi-job operation
INTERVAL=${HOME}/exome/db/interval_list_hg19_nongap

# log dir 
LOGDIR=${HOME}/exome/log/ebcall

# path to annovar
ANNOPATH=${HOME}/exome/bin/annovar


