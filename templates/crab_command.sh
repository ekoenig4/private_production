#!/bin/bash

source crabenv.sh

pushd $CMSSW_VERSION/src > /dev/null
eval `scram runtime -sh`
popd > /dev/null

source /cvmfs/cms.cern.ch/crab3/crab.sh prod

crab $@
