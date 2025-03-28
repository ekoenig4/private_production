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

# LHE and GEN-SIM step
export SCRAM_ARCH=el8_amd64_gcc10
build_cmssw 13_0_13
run 0_HIG-Run3Summer23wmLHEGS \
    Configuration/GenProduction/python/fragment.py \
    --fileout "file:0_HIG-Run3Summer23wmLHEGS.root" \
    --eventcontent RAWSIM,LHE \
    --customise Configuration/DataProcessing/Utils.addMonitoring \
    --datatier GEN-SIM,LHE \
    --conditions 130X_mcRun3_2023_realistic_v14 \
    --beamspot Realistic25ns13p6TeVEarly2023Collision \
    --customise_commands process.RandomNumberGeneratorService.externalLHEProducer.initialSeed="int(${SEED})"\\nprocess.source.firstLuminosityBlock="cms.untracked.uint32(${JOBNUM})"\\nprocess.source.numberEventsInLuminosityBlock="cms.untracked.uint32(${EVENTS})" \
    --step LHE,GEN,SIM \
    --geometry DB:Extended \
    --era Run3_2023 \
    --no_exec \
    --mc || exit $? ;

# premixing step
export SCRAM_ARCH=el8_amd64_gcc10
build_cmssw 13_0_13
run 1_HIG-Run3Summer23DRPremix \
    --filein "file:0_HIG-Run3Summer23wmLHEGS.root" \
    --fileout "file:1_HIG-Run3Summer23DRPremix.root" \
    --eventcontent PREMIXRAW \
    --customise Configuration/DataProcessing/Utils.addMonitoring \
    --datatier GEN-SIM-RAW \
    --pileup_input "filelist:pileup_files_on_disk.txt" \
    --conditions 130X_mcRun3_2023_realistic_v14 \
    --step DIGI,DATAMIX,L1,DIGI2RAW,HLT:2023v12 \
    --procModifiers premix_stage2 \
    --geometry DB:Extended \
    --datamix PreMix \
    --era Run3_2023 \
    --no_exec \
    --mc || exit $? ;

# AOD step
export SCRAM_ARCH=el8_amd64_gcc10
build_cmssw 13_0_13
run 2_HIG-Run3Summer23AOD \
    --filein "file:1_HIG-Run3Summer23DRPremix.root" \
    --fileout "file:2_HIG-Run3Summer23AOD.root" \
    --eventcontent AODSIM \
    --customise Configuration/DataProcessing/Utils.addMonitoring \
    --datatier AODSIM \
    --conditions 130X_mcRun3_2023_realistic_v14 \
    --step RAW2DIGI,L1Reco,RECO,RECOSIM \
    --geometry DB:Extended \
    --era Run3_2023 \
    --no_exec \
    --mc || exit $? ;

# MiniAOD step
export SCRAM_ARCH=el8_amd64_gcc11
build_cmssw 13_0_13
run 3_HIG-Run3Summer23MiniAODv4 \
    --filein "file:2_HIG-Run3Summer23AOD.root" \
    --fileout "file:3_HIG-Run3Summer23MiniAODv4.root" \
    --eventcontent MINIAODSIM \
    --customise Configuration/DataProcessing/Utils.addMonitoring \
    --datatier MINIAODSIM \
    --conditions 130X_mcRun3_2023_realistic_v14 \
    --step PAT \
    --geometry DB:Extended \
    --era Run3_2023 \
    --no_exec \
    --mc || exit $? ;

# NanoAOD step
export SCRAM_ARCH=el8_amd64_gcc11
build_cmssw 13_0_13
run 4_HIG-Run3Summer23NanoAODv12 \
    --filein "file:3_HIG-Run3Summer23MiniAODv4.root" \
    --fileout "file:ntuple.root" \
    --eventcontent NANOAODSIM \
    --customise Configuration/DataProcessing/Utils.addMonitoring \
    --datatier NANOAODSIM \
    --conditions 130X_mcRun3_2023_realistic_v14 \
    --step NANO \
    --scenario pp \
    --era Run3_2023 \
    --no_exec \
    --mc || exit $? ;

echo "================= CMSRUN finished ===================="
