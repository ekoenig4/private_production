#!/bin/bash 

# Usage: sh input/ZHto4b_Run3/build_simpacks.sh

version=$1

if [ ! -z $version ]; then
    version="_${version}"
fi

conditions=(
    2021/2022-preEE
    2022/2022-postEE
    2023/2023-preBPIX
    2020/2023-postBPIX
)

GRIDPATH=/cmsuf/data/store/user/ekoenig/gridpacks

for condition in ${conditions[@]}; do
    year=$(dirname $condition)
    condition=$(basename $condition)

    python build_simpack.py \
        -g ${GRIDPATH}/ZHto4b_Run3/HZJ_13p6TeV_slc7_amd64_gcc10_CMSSW_12_4_21_ZH.tgz \
        -f ${GRIDPATH}/ZHto4b_Run3/ZHto4B_powheg.py \
        -c ../conditions/conditions-${condition} \
        --container cmssw-el8 \
        -s T2_US_Florida \
        -o private-sample-production/${year}/mc \
        -n ZH_ZToBB_HToBB_M-125_${condition}${version} \
        --sample_name ZH_ZToBB_HToBB_M-125_${condition} \
        --events_per_job 500 \
        --total_events 5000000
done
