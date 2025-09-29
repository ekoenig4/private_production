#!/bin/bash

source crabenv.sh

# if hostname ends with .ufhpc, then we are on UF HPC
if [[ $(hostname) == *.ufhpc ]]; then
    source /cvmfs/oasis.opensciencegrid.org/osg-software/osg-wn-client/current/el9-x86_64/setup.sh
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/cmsuf/podman/data1/lib
    export PATH=$PATH:/cmsuf/podman/data1/bin
fi

scram p CMSSW $CMSSW_VERSION
pushd $CMSSW_VERSION/src
eval `scram runtime -sh`
popd

source /cvmfs/cms.cern.ch/crab3/crab.sh

crab submit -c crab_config.py
