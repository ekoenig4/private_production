#!/bin/bash 

#SBATCH --job-name=hpg_merge
#SBATCH --account=avery
#SBATCH --qos=avery-b
#SBATCH --partition=hpg-dev
#SBATCH --cpus-per-task=16
#SBATCH --mem-per-cpu=4G
#SBATCH --time=02:00:00
#SBATCH --output=logs/hpg_merge_%j.out

export N_MERGED_FILES=500

# --- Parse command line arguments
export INPUT=`realpath $1`
if [ ! -d $INPUT ]; then
    echo "Input directory does not exist: $INPUT"
    exit 1
fi

OUTPUT=$2
if [ -z $OUTPUT ]; then
    echo "Output directory not specified"
    exit 1
fi

# For EOS Storage
# # ssh hostname for storage
# HOSTNAME=lxplus
# # root://hostname/ for storage
# ROOTNAME=eosuser.cern.ch
# STORAGE=/eos/user/j/jacobo/Run3_private_production
# echo "Storage output: $HOSTNAME:$STORAGE/$OUTPUT"
# # create output in storage if not already there
# ssh $HOSTNAME -t "cd $STORAGE && mkdir -p $OUTPUT" || {
#     echo "Failed to create output directory $STORAGE/$OUTPUT"
#     exit 1
# }
# export OUTPUT=$STORAGE/$OUTPUT

# For local storage
STORAGE=/cmsuf/data/store/user/ekoenig/Run3_private_production
echo "Storage output: $STORAGE/$OUTPUT"
export OUTPUT=$STORAGE/$OUTPUT
mkdir -p $OUTPUT

# --- Setup environment
source /cvmfs/cms.cern.ch/cmsset_default.sh

CMSSW=/blue/avery/ekoenig/analysis/CMSSW_13_3_1
cd $CMSSW/src || {
    echo "Failed to find directory $CMSSW/src"
    exit 1
}
echo "CMSSW: $CMSSW"
eval `scramv1 runtime -sh`
cd -

# split input files into $N_MERGED_FILES chunks
FILES=`find $INPUT -name "*.root" | sort`
export FILES=($FILES)
export N_FILES=${#FILES[@]}
echo "Found $N_FILES files in $INPUT"

# --- Setup array job
function hadd() {
    SLURM_ARRAY_TASK_ID=$1

    # split N_FILES into $N_MERGED_FILES chunks
    FILES=`find $INPUT -name "*.root" | sort`
    FILES=($FILES)
    N_FILES=${#FILES[@]}

    FILES_PER_JOB=$((N_FILES / N_MERGED_FILES))
    FILES_START=$((SLURM_ARRAY_TASK_ID * FILES_PER_JOB))
    FILES_END=$((FILES_START + FILES_PER_JOB))
    if [ $SLURM_ARRAY_TASK_ID -eq $((N_MERGED_FILES - 1)) ]; then
        FILES_END=$N_FILES
    fi
    HADD_FILES=(${FILES[@]:$FILES_START:$FILES_PER_JOB})
    N_HADD_FILES=${#HADD_FILES[@]}
    echo "Processing files $FILES_START to $FILES_END ($N_HADD_FILES files)"

    TMPFILE=$TMPDIR/ntuple_merged_${SLURM_ARRAY_TASK_ID}.root
    echo haddnano.py $TMPFILE ...
    haddnano.py $TMPFILE ${HADD_FILES[@]} || {
        echo "Failed to merge files"
        rm -fv $TMPFILE
        exit 1
    }

    echo "hadd done ${SLURM_ARRAY_TASK_ID}/${N_MERGED_FILES}"
}

export -f hadd

MAX_TASK_ID=$((N_MERGED_FILES - 1))
seq 0 $MAX_TASK_ID | xargs -n 1 -P $SLURM_CPUS_PER_TASK -I {} bash -c "hadd {}"
 
# copy all $TMPDIR/ntuple_merged_${SLURM_ARRAY_TASK_ID}.root files to storage
TMPFILES=`find $TMPDIR -name "ntuple_merged_*.root"`
TMPFILE=($TMPFILES)
N_TMPFILES=${#TMPFILE[@]}
echo "Found $N_TMPFILES merged files in $TMPDIR"

# For EOS Storage
# echo "Copying $TMPFILES to $HOSTNAME:$OUTPUT ..."
# xrdcp -f --parallel $SLURM_CPUS_PER_TASK $TMPFILES root://${ROOTNAME}/$OUTPUT || {
#     echo "Failed to copy files to storage"
#     exit 1
# }

# For local storage
echo "Copying $TMPFILES to $OUTPUT ..."
mv -v $TMPFILES $OUTPUT || {
    echo "Failed to copy files to storage"
    exit 1
}