#!/bin/bash

export SCRAM_ARCH=el8_amd64_gcc11
export CMSSW_VERSION=CMSSW_13_0_13

pushd $CMSSW_VERSION/src > /dev/null
eval `scram runtime -sh`
popd > /dev/null

source /cvmfs/cms.cern.ch/crab3/crab.sh prod

crab $@
