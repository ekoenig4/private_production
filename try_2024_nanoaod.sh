#!/bin/sh 

NANOAOD=/cmsuf/data/store/user/ekoenig/private-sample-production/2024/mc/CRAB_PrivateMC/NMSSM_XToYH_YToHH_HToBB_MX_700_MY_400_2024/250930_081811/0000/ntuple_1.root

source /cvmfs/cms.cern.ch/cmsset_default.sh

cmssw-el8 -- <<EOF

cd /cvmfs/cms.cern.ch/el8_amd64_gcc12/cms/cmssw/CMSSW_15_0_4/src/
cmsenv
cd -

root -l $NANOAOD -b -e 'Events->Print();'

EOF