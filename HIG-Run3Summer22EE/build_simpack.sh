BASE=simulation
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

SIMPACK=$(basename $GRIDPACK .tar.xz)

echo "Building simulation package $SIMPACK"
mkdir -p $BASE/$SIMPACK
cp -v $GRIDPACK $BASE/$SIMPACK/gridpack.tar.xz
cp -rv $TEMPLATE/* $BASE/$SIMPACK

cat <<EOF > $BASE/$SIMPACK/crabConfig.py
from CRABClient.UserUtilities import config
config = config()

config.General.requestName     = '${SIMPACK}'
config.General.workArea        = '${SIMPACK}'
config.General.transferOutputs = True
config.General.transferLogs    = False

config.Data.splitting   = 'EventBased'
config.Data.unitsPerJob = 10
config.Data.totalUnits  = 50
config.Data.outLFNDirBase = '/store/user/ekoenig/private_production/HIG-Run3Summer22EE/'
config.Data.publication = False
config.Data.outputDatasetTag     = '${SIMPACK}'

config.JobType.pluginName  = 'PrivateMC'
config.JobType.psetName    = 'nanoAOD_cfi.py'
config.JobType.maxMemoryMB = 2500
config.JobType.inputFiles  = ['scriptExe.sh', 'Configuration', 'gridpack.tar.xz']
config.JobType.scriptExe   ='scriptExe.sh'
config.JobType.scriptArgs  = [ 'events='+str(config.Data.unitsPerJob) ]
config.JobType.numCores    = 1

# config.Site.storageSite = 'T3_US_FNALLPC'
config.Site.storageSite = 'T3_CH_CERNBOX'
EOF