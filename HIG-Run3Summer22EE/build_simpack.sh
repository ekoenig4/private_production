
if [ -z $BASE ]; then
    BASE=simulation
fi
TEMPLATE=Template

GRIDPACK=$1
if [ -z $GRIDPACK ]; then
    echo "Usage: $0 <gridpack.tar.xz>"
    exit 1
fi

if [ ! -f $GRIDPACK ]; then
    echo "Gridpack $GRIDPACK not found"
    exit 1
fi

TYPE="${2#type=}"
if [ -z $TYPE ]; then 
    TYPE=madgraph
fi
echo "Using gridpack type: $TYPE"

CONTAINER="${3#container=}"
if [ -z $CONTAINER ]; then
    CONTAINER=cmssw-el8
fi
echo "Using container: $CONTAINER"

SIMPACK=$(basename $GRIDPACK .tar.xz)

echo "Building simulation package $SIMPACK"

if [ -d $BASE/$SIMPACK ]; then
    echo "Removing existing simpack"
    rm -r $BASE/$SIMPACK
fi

mkdir -p $BASE/$SIMPACK
cp -v $GRIDPACK $BASE/$SIMPACK/gridpack.tar.xz
cp -rv $TEMPLATE/* $BASE/$SIMPACK

cat <<EOF > $BASE/$SIMPACK/wrapper.sh
source /cvmfs/cms.cern.ch/cmsset_default.sh
$CONTAINER --command-to-run sh scriptExe.sh \$@ 2>&1 | tee -a output.log
EOF

cat <<EOF > $BASE/$SIMPACK/crabConfig.py
from CRABClient.UserUtilities import config
config = config()

config.General.requestName     = '${SIMPACK}'
config.General.workArea        = '${SIMPACK}'
config.General.transferOutputs = True
config.General.transferLogs    = False

config.Data.splitting   = 'EventBased'
config.Data.unitsPerJob = 10
config.Data.totalUnits  = 10*10
config.Data.outLFNDirBase = '/store/user/ekoenig/private_production/HIG-Run3Summer22EE/'
config.Data.publication = False
config.Data.outputDatasetTag     = '${SIMPACK}'

config.JobType.pluginName  = 'PrivateMC'
config.JobType.psetName    = 'nanoAOD_cfi.py'
config.JobType.maxMemoryMB = 3500
config.JobType.inputFiles  = ['wrapper.sh', 'scriptExe.sh', 'Configuration', 'gridpack.tar.xz']
config.JobType.scriptExe   ='wrapper.sh'
config.JobType.scriptArgs  = [ 'events='+str(config.Data.unitsPerJob), 'type=${TYPE}' ]
config.JobType.numCores    = 1

# config.Site.storageSite = 'T3_US_FNALLPC'
config.Site.storageSite = 'T3_CH_CERNBOX'
EOF
