export SCRAM_ARCH=el8_amd64_gcc12
export CMSSW_VERSION=CMSSW_15_0_4

source /cvmfs/cms.cern.ch/cmsset_default.sh

# if hostname ends with .ufhpc, then we are on UF HPC
if [[ $(hostname) == *.ufhpc ]]; then
    source /cvmfs/oasis.opensciencegrid.org/osg-software/osg-wn-client/3.6/current/el9-x86_64/setup.sh
    export X509_CERT_DIR=/cvmfs/cms.cern.ch/grid/etc/grid-security/certificates
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/cmsuf/podman/data1/lib
    export PATH=$PATH:/cmsuf/podman/data1/bin
fi

if [ ! -r $CMSSW_VERSION/src ]; then
    scram p CMSSW $CMSSW_VERSION
fi

pushd $CMSSW_VERSION/src
eval `scram runtime -sh`
popd