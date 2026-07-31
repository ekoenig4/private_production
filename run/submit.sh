#!/bin/bash 

#SBATCH --account=avery
#SBATCH --qos=avery-b
#SBATCH --partition=hpg-dev
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=1G
#SBATCH --time=05:00:00
#SBATCH --output=logs/submit_%j.out

source /cvmfs/cms.cern.ch/cmsset_default.sh
source /cvmfs/oasis.opensciencegrid.org/osg-software/osg-wn-client/current/el9-x86_64/setup.sh
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/cmsuf/podman/data1/lib
export PATH=$PATH:/cmsuf/podman/data1/bin
source /cvmfs/cms.cern.ch/crab3/crab.sh

for simpack in $@; do 
    pushd $simpack 
    ./crab_submit.sh 
    popd
done