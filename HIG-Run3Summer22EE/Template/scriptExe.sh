#!/bin/bash

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

BASE=$PWD
SEED=$(($(date +%s) % 100 + $JOBNUM))

echo "================= CMSRUN starting jobNum=$1 ====================" | tee -a job.log
source /cvmfs/cms.cern.ch/cmsset_default.sh

build_cmssw() {
    VERSION=$1

    echo "================= CMSRUN setting up CMSSW_$VERSION ===================="| tee -a job.log
    if [ -r CMSSW_$VERSION/src ] ; then 
    echo release CMSSW_$VERSION already exists
    
    cd CMSSW_$VERSION/src
    eval `scram runtime -sh`

    cd $BASE
    
    else
    scram p CMSSW CMSSW_$VERSION

    if [ ! -f CMSSW_$VERSION/src/Configuration ]; then
        cp -r Configuration CMSSW_$VERSION/src
    fi
    
    cd CMSSW_$VERSION/src
    eval `scram runtime -sh`
    scram b

    cd $BASE
    fi
}

run() {

    export SCRIPT=$1
    REPORT_NAME=FrameworkJobReport.xml
    shift 1

    export ARGS=$@

    echo "================= CMSRUN setting up $SCRIPT step ====================" | tee -a job.log

    cmsDriver.py $ARGS --python_filename $SCRIPT.py -n $EVENTS || exit $? ;

    echo "================= CMSRUN starting $SCRIPT step ====================" | tee -a job.log

    cmsRun -e -j $REPORT_NAME $SCRIPT.py
    status=$?

    if [ $status -ne 0 ]; then
        echo "================= CMSRUN error with exit status $status ====================" | tee -a job.log
        rm -f *.root
        exit $status
    fi

}

export SCRAM_ARCH=el8_amd64_gcc10
build_cmssw 12_4_14_patch3
run 0_HIG-Run3Summer22EEwmLHEGS \
    Configuration/GenProduction/python/HIG-Run3Summer22EEwmLHEGS-00282-fragment.py \
    --fileout "file:0_HIG-Run3Summer22EEwmLHEGS.root" \
    --eventcontent RAWSIM,LHE --customise Configuration/DataProcessing/Utils.addMonitoring --datatier GEN-SIM,LHE --conditions 124X_mcRun3_2022_realistic_postEE_v1 --beamspot Realistic25ns13p6TeVEarly2022Collision --customise_commands process.RandomNumberGeneratorService.externalLHEProducer.initialSeed="int(${SEED})"\\nprocess.source.firstLuminosityBlock="cms.untracked.uint32(${JOBNUM})"\\nprocess.source.numberEventsInLuminosityBlock="cms.untracked.uint32(${EVENTS})" --step LHE,GEN,SIM --geometry DB:Extended --era Run3 --no_exec --mc || exit $? ;

export SCRAM_ARCH=el8_amd64_gcc10
build_cmssw 12_4_14_patch3
run 1_HIG-Run3Summer22EEDRPremix \
    --filein "file:0_HIG-Run3Summer22EEwmLHEGS.root" \
    --fileout "file:1_HIG-Run3Summer22EEDRPremix.root" \
    --eventcontent PREMIXRAW --customise Configuration/DataProcessing/Utils.addMonitoring --datatier GEN-SIM-RAW --pileup_input "dbs:/Neutrino_E-10_gun/Run3Summer21PrePremix-Summer22_124X_mcRun3_2022_realistic_v11-v2/PREMIX" --conditions 124X_mcRun3_2022_realistic_postEE_v1 --step DIGI,DATAMIX,L1,DIGI2RAW,HLT:2022v14 --procModifiers premix_stage2,siPixelQualityRawToDigi --geometry DB:Extended  --datamix PreMix --era Run3 --no_exec --mc || exit $? ;


export SCRAM_ARCH=el8_amd64_gcc10
build_cmssw 12_4_14_patch3
run 2_HIG-Run3Summer22EEAOD \
    --filein "file:1_HIG-Run3Summer22EEDRPremix.root" \
    --fileout "file:2_HIG-Run3Summer22EEAOD.root" \
    --eventcontent AODSIM --customise Configuration/DataProcessing/Utils.addMonitoring --datatier AODSIM --conditions 124X_mcRun3_2022_realistic_postEE_v1 --step RAW2DIGI,L1Reco,RECO,RECOSIM --procModifiers siPixelQualityRawToDigi --geometry DB:Extended --era Run3 --no_exec --mc || exit $? ;

export SCRAM_ARCH=el8_amd64_gcc11
build_cmssw 13_0_13
run 3_HIG-Run3Summer22EEMiniAODv4 \
    --filein "file:2_HIG-Run3Summer22EEAOD.root" \
    --fileout "file:3_HIG-Run3Summer22EEMiniAODv4.root" \
    --eventcontent MINIAODSIM --customise Configuration/DataProcessing/Utils.addMonitoring --datatier MINIAODSIM --conditions 130X_mcRun3_2022_realistic_postEE_v6 --step PAT --geometry DB:Extended --era Run3,run3_miniAOD_12X --no_exec --mc || exit $? ;

export SCRAM_ARCH=el8_amd64_gcc11
build_cmssw 13_0_13
run 4_HIG-Run3Summer22EENanoAODv12 \
    --filein "file:3_HIG-Run3Summer22EEMiniAODv4.root" \
    --fileout "file:ntuple.root" \
    --eventcontent NANOAODSIM --customise Configuration/DataProcessing/Utils.addMonitoring --datatier NANOAODSIM --conditions 130X_mcRun3_2022_realistic_postEE_v6 --step NANO --scenario pp --era Run3 --no_exec --mc || exit $? ;

echo "================= CMSRUN finished ====================" | tee -a job.log