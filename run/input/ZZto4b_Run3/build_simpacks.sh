#!/bin/bash 

# Usage: sh input/ZZto4b_Run3/build_simpacks.sh

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
        -g ${GRIDPATH}/ZZto4b_Run3/ZZTo4B01j_5f_NLO_FXFX_slc7_amd64_gcc10_CMSSW_12_4_21_tarball.tar.xz \
        -f ${GRIDPATH}/ZZto4b_Run3/ZZto4B_madgraph.py \
        -c ../conditions/conditions-${condition} \
        --container cmssw-el8 \
        -n ZZTo4B01j_5f_NLO_FXFX_${condition}${version} \
        --sample_name ZZTo4B01j_5f_NLO_FXFX_${condition} \
        --events_per_job 500 \
        --total_events 5000000
done
