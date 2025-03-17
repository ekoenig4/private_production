#!/bin/bash 

# Usage: sh input/ZZto4b_Run3/build_simpacks.sh

conditions=(
    2022-preEE
    # 2022-postEE
    # 2023-preBPIX
    # 2023-postBPIX
)

for condition in ${conditions[@]}; do
    python build_simpack.py \
        -g input/ZHto4b_Run3/ZH_HToBB_ZToBB_M-125_slc7_amd64_gcc10_CMSSW_12_4_21_ZH.tgz \
        -f input/ZHto4b_Run3/ZHto4b_fragment.py \
        -c ../conditions/conditions-${condition} \
        --container cmssw-el8 \
        -n ZH_HToBB_ZToBB_M-125_${condition} \
        --sample_name ZH_HToBB_ZToBB_M-125_${condition} \
        --events_per_job 100 \
        --total_events 10000
done
