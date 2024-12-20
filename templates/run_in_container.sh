#!/bin/bash

source /cvmfs/cms.cern.ch/cmsset_default.sh

# run crab_run.sh in a specified container
$CONTAINER --command-to-run ./nanoaod_run.sh $@ 2>&1 | tee -a output.log
