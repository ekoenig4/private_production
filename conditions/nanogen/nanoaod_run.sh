#!/bin/bash

# parse command line args
# (job number and number of events)

JOBNUM=$1
if [ -z $JOBNUM ]; then
    echo "Please provide a job number"
    exit 1
fi

EVENTS="${2#events=}"
if [ -z $EVENTS ]; then
    EVENTS=10
    echo "Using default number of events: $EVENTS"
fi

# store current working directory for later use
BASE=$PWD

# set the random seed
SEED=$(($(date +%s) % 100 + $JOBNUM))

# define auxiliary functions

build_cmssw() {
    # install a specified CMSSW version

    VERSION=$1

    echo "================= CMSRUN setting up CMSSW_$VERSION ===================="
    if [ -r CMSSW_$VERSION/src ] ; then 
      echo release CMSSW_$VERSION already exists
    else
      scram p CMSSW CMSSW_$VERSION
    fi

    if [ ! -f CMSSW_$VERSION/src/Configuration ]; then
        cp -r Configuration CMSSW_$VERSION/src
    fi
    
    cd CMSSW_$VERSION/src
    eval `scram runtime -sh`
    scram b

    cd $BASE
}

run() {
    # build and run a specified configuration file with cmsDriver and cmsRun

    export SCRIPT=$1
    REPORT_NAME=FrameworkJobReport.xml
    shift 1

    export ARGS=$@

    echo "================= CMSRUN setting up $SCRIPT step ===================="

    cmsDriver.py $ARGS --python_filename $SCRIPT.py -n $EVENTS || exit $? ;

    echo "================= CMSRUN starting $SCRIPT step ===================="

    cmsRun -e -j $REPORT_NAME $SCRIPT.py
    status=$?

    if [ $status -ne 0 ]; then
        echo "================= CMSRUN error with exit status $status ===================="
        rm -f *.root
        exit $status
    fi

}

# main

echo "================= CMSRUN starting jobNum=$1 ===================="
source /cvmfs/cms.cern.ch/cmsset_default.sh

# NanoGen step
export SCRAM_ARCH=el8_amd64_gcc10
build_cmssw 12_4_14_patch3
run 0_HIG-Run3Summer22wmLHEGS \
    Configuration/GenProduction/python/fragment.py \
    --fileout "file:ntuple.root" \
    --eventcontent NANOAODGEN \
    --customise Configuration/DataProcessing/Utils.addMonitoring \
    --datatier NANOAOD \
    --conditions auto:mc \
    --customise_commands process.RandomNumberGeneratorService.externalLHEProducer.initialSeed="int(${SEED})"\\nprocess.source.firstLuminosityBlock="cms.untracked.uint32(${JOBNUM})"\\nprocess.source.numberEventsInLuminosityBlock="cms.untracked.uint32(${EVENTS})" \
    --step LHE,GEN,NANOGEN \
    --no_exec \
    --mc || exit $? ;

echo "================= CMSRUN finished ===================="
