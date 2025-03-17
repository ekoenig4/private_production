
CMSSW=/afs/cern.ch/user/e/ekoenig/WORKINGAREA/4BAnalysis/CMSSW_13_3_1
cd $CMSSW/src
eval `scram runtime -sh`
cd -

INPUTS=(
    /eos/user/e/ekoenig/private-sample-production/CRAB_PrivateMC/ZZTo4B01j_5f_NLO_FXFX_2022-preEE/
    /eos/user/e/ekoenig/private-sample-production/CRAB_PrivateMC/ZZTo4B01j_5f_NLO_FXFX_2022-postEE/
    /eos/user/e/ekoenig/private-sample-production/CRAB_PrivateMC/ZZTo4B01j_5f_NLO_FXFX_2023-preBPIX/
    /eos/user/e/ekoenig/private-sample-production/CRAB_PrivateMC/ZZTo4B01j_5f_NLO_FXFX_2023-postBPIX/
)

OUTPUTS=(
    /eos/user/m/mkolosov/Run3_HHTo4B_NTuples/Custom/2021/mc/ZZTo4B01j_5f_NLO_FXFX_2022-preEE/
    /eos/user/m/mkolosov/Run3_HHTo4B_NTuples/Custom/2022/mc/ZZTo4B01j_5f_NLO_FXFX_2022-postEE/
    /eos/user/m/mkolosov/Run3_HHTo4B_NTuples/Custom/2023/mc/ZZTo4B01j_5f_NLO_FXFX_2023-preBPIX/
    /eos/user/m/mkolosov/Run3_HHTo4B_NTuples/Custom/2020/mc/ZZTo4B01j_5f_NLO_FXFX_2023-postBPIX/
)

JOBID=$1

INPUT_PATH=${INPUTS[${JOBID}]}
OUTPUT_PATH=${OUTPUTS[${JOBID}]}

echo "INPUT_PATH: ${INPUT_PATH}"
if [ ! -d ${INPUT_PATH} ]; then
    echo "Input path does not exist!"
    exit 1
fi

echo "OUTPUT_PATH: ${OUTPUT_PATH}"
if [ ! -d ${OUTPUT_PATH} ]; then
    echo "Output path does not exist!"
    exit 1
fi

N_MERGED=100

for subdir in `ls ${INPUT_PATH}`; do
    N_FILES=`find ${INPUT_PATH}/${subdir} -name "*.root" | wc -l`
    echo "Subdir: ${subdir}"


    JOB_SIZE=$((N_FILES / N_MERGED))
    if [ $((N_FILES % N_MERGED)) -ne 0 ]; then
        JOB_SIZE=$((JOB_SIZE + 1))
    fi

    python3 merge.py \
        -s ${INPUT_PATH}/${subdir} \
        -o ${OUTPUT_PATH}/${subdir} \
        --cmssw ${CMSSW} \
        -g $JOB_SIZE 
done
