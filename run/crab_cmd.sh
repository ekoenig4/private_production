#!/bin/bash 

#SBATCH --account=avery
#SBATCH --qos=avery-b
#SBATCH --partition=hpg-dev
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=1G
#SBATCH --time=00:10:00
#SBATCH --output=logs/crab_cmd_%j.out

source /cvmfs/cms.cern.ch/cmsset_default.sh
source /cvmfs/oasis.opensciencegrid.org/osg-software/osg-wn-client/current/el9-x86_64/setup.sh
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/cmsuf/podman/data1/lib
export PATH=$PATH:/cmsuf/podman/data1/bin
source /cvmfs/cms.cern.ch/crab3/crab.sh

cd /blue/avery/ekoenig/analysis/CMSSW_13_3_1/src
eval `scramv1 runtime -sh`
cd -

crab $@