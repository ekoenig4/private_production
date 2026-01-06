#!/bin/bash 

# Usage: sh input/ZZto4b_Run3/build_simpacks.sh

version=$1

if [ ! -z $version ]; then
    version="_${version}"
fi

masses=(
    MX_450_MY_250
    MX_700_MY_250
    MX_700_MY_400
    MX_700_MY_500
    MX_1200_MY_250
    MX_1200_MY_400
    MX_1200_MY_500
)

conditions=(
    # 2021/2022-preEE
    # 2022/2022-postEE
    # 2023/2023-preBPIX
    # 2020/2023-postBPIX
    2024/2024
)

# GRIDPATH=/eos/home-e/ekoenig/gridpacks/NMSSM_XToYH_YToHH_Run3
GRIDPATH=/blue/avery/ekoenig/analysis/private_gridpacks/gridpacks

for mass in ${masses[@]}; do
    echo "Processing mass point: $mass"
    for condition in ${conditions[@]}; do
        year=$(dirname $condition)
        condition=$(basename $condition)
        python build_simpack.py \
            -g ${GRIDPATH}/NMSSM_XToYH_YToHH_${mass}_el8_amd64_gcc10_CMSSW_12_4_8_tarball.tar.xz \
            -f input/NMSSM_XToYH_YToHH_HToBB_Run3/fragment.py \
            -c ../conditions/conditions-${condition} \
            --container cmssw-el8 \
            -s T2_US_Florida \
            -o private-sample-production/${year}/mc \
            -n NMSSM_XToYH_YToHH_HToBB_${mass}_${condition}${version} \
            --sample_name NMSSM_XToYH_YToHH_HToBB_${mass}_${condition} \
            --events_per_job 500 \
            --total_events 10000
    done
done
