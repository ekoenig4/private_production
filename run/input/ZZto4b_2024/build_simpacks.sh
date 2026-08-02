#!/bin/bash 

# Usage: sh input/ZZto4b_2024/build_simpacks.sh

version=$1

if [ ! -z $version ]; then
    version="_${version}"
fi

GRIDPACK=/blue/avery/ekoenig/genproduction/gridpacks/ZZTo4Q01j_5f_NLO_FXFX/genproductions_scripts/bin/MadGraph5_aMCatNLO/ZZTo4B01j_5f_NLO_FXFX_el8_amd64_gcc12_CMSSW_12_4_8_tarball.tar.xz
# GRIDPACK=/blue/avery/ekoenig/genproduction/gridpacks/ZZTo4B01j_5f_NLO_FXFX/genproductions_scripts/bin/MadGraph5_aMCatNLO/ZZTo4B01j_5f_NLO_FXFX_el8_amd64_gcc12_CMSSW_12_4_8_tarball.tar.xz
FRAGMENT=/home/ekoenig/blue/genproduction/cards/genfragments/production/13p6TeV/ZZTo4B01j_5f_NLO_FXFX/ZZto4B_madgraph.py

year=2024
condition=2024
python build_simpack.py \
    -g ${GRIDPACK} \
    -f ${FRAGMENT} \
    -c ../conditions/conditions-${condition} \
    --container cmssw-el8 \
    -s T2_US_Florida \
    -o private-sample-production/${year}/mc \
    -n ZZTo4B01j_5f_NLO_FXFX_${condition}${version} \
    --sample_name ZZTo4B01j_5f_NLO_FXFX_${condition} \
    --events_per_job 500 \
    --total_events 5000 