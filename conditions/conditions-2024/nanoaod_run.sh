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

export SCRAM_ARCH=el8_amd64_gcc12
build_cmssw 14_0_21
run 0_HIG-RunIII2024Summer24wmLHEGS \
    Configuration/GenProduction/python/fragment.py \
    --era Run3_2024 \
    --customise Configuration/DataProcessing/Utils.addMonitoring \
    --beamspot DBrealistic \
    --step LHE,GEN,SIM \
    --geometry DB:Extended \
    --conditions 140X_mcRun3_2024_realistic_v26 \
    --customise_commands process.RandomNumberGeneratorService.externalLHEProducer.initialSeed="int(${SEED})"\\nprocess.source.numberEventsInLuminosityBlock="cms.untracked.uint32(100)" \
    --datatier GEN-SIM,LHE \
    --eventcontent RAWSIM,LHE \
    --fileout file:0_HIG-RunIII2024Summer24wmLHEGS-00730.root \
    --no_exec \
    --mc || exit $? ;

run 1_HIG-RunIII2024Summer24DRPremix \
    --era Run3_2024 \
    --customise Configuration/DataProcessing/Utils.addMonitoring \
    --procModifiers premix_stage2 \
    --datamix PreMix \
    --step DIGI,DATAMIX,L1,DIGI2RAW,HLT:2024v14 \
    --geometry DB:Extended \
    --conditions 140X_mcRun3_2024_realistic_v26 \
    --datatier GEN-SIM-RAW \
    --eventcontent PREMIXRAW \
    --fileout file:1_HIG-RunIII2024Summer24DRPremix-00302_0.root \
    --filein file:0_HIG-RunIII2024Summer24wmLHEGS-00730.root \
    --pileup_input "dbs:/Neutrino_E-10_gun/RunIIISummer24PrePremix-Premixlib2024_140X_mcRun3_2024_realistic_v26-v1/PREMIX" \
    --no_exec \
    --mc || exit $? ;

run 2_HIG-RunIII2024Summer24DRPremix \
    --era Run3_2024 \
    --customise Configuration/DataProcessing/Utils.addMonitoring \
    --step RAW2DIGI,L1Reco,RECO,RECOSIM \
    --geometry DB:Extended \
    --conditions 140X_mcRun3_2024_realistic_v26 \
    --datatier AODSIM \
    --eventcontent AODSIM \
    --fileout file:2_HIG-RunIII2024Summer24DRPremix-00302.root \
    --filein file:1_HIG-RunIII2024Summer24DRPremix-00302_0.root \
    --no_exec \
    --mc || exit $? ;

build_cmssw 15_0_4
run 3_HIG-RunIII2024Summer24MiniAODv6 \
    --era Run3_2024 \
    --customise Configuration/DataProcessing/Utils.addMonitoring \
    --step PAT \
    --geometry DB:Extended \
    --conditions 150X_mcRun3_2024_realistic_v2 \
    --datatier MINIAODSIM \
    --eventcontent MINIAODSIM1 \
    --fileout file:3_HIG-RunIII2024Summer24MiniAODv6-00302.root \
    --filein file:2_HIG-RunIII2024Summer24DRPremix-00302.root \
    --no_exec \
    --mc || exit $? ;

# NanoAOD step
run 4_HIG-RunIII2024Summer24NanoAODv15 \
    --scenario pp \
    --era Run3_2024 \
    --customise Configuration/DataProcessing/Utils.addMonitoring \
    --step NANO \
    --conditions 150X_mcRun3_2024_realistic_v2 \
    --datatier NANOAODSIM \
    --eventcontent NANOAODSIM \
    --python_filename HIG-RunIII2024Summer24NanoAODv15-00303_1_cfg.py \
    --fileout file:ntuple.root \
    --filein file:3_HIG-RunIII2024Summer24MiniAODv6-00302.root \
    --no_exec \
    --mc || exit $? ;

echo "================= CMSRUN finished ===================="
