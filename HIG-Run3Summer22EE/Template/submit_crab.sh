export SCRAM_ARCH=el8_amd64_gcc11
export CMSSW_VERSION=CMSSW_13_0_13

scram p CMSSW $CMSSW_VERSION
pushd $CMSSW_VERSION/src
eval `scram runtime -sh`
popd

source /cvmfs/cms.cern.ch/crab3/crab.sh

crab submit -c crabConfig.py
