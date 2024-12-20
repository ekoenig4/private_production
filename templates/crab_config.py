from CRABClient.UserUtilities import config

config = config()

# set the CRAB working directory (where log files will appear)
config.General.workArea        = 'crab_logs'
# set the folder within the CRAB working directory for a specific submission
config.General.requestName     = 'private_sample'
config.General.transferOutputs = True
config.General.transferLogs    = False

config.Data.splitting   = 'EventBased'
# set the number of events per job
config.Data.unitsPerJob = 10
# set the total number of events
# (the number of jobs will be totalUnits/unitsPerJob)
config.Data.totalUnits  = 10
# set the output directory
# note that /store/user/<username> is automatically translated by CRAB
# to a physical file location, depending on the storage site.
# for example using site T3_CH_CERNBOX, this path translates to
# /eos/user/<initial>/<username>
config.Data.outLFNDirBase = '/store/user/$USER/private-sample-production/'
config.Data.publication = False
# set the name of the sample
config.Data.outputDatasetTag = 'test_sample'

config.JobType.pluginName  = 'PrivateMC'
config.JobType.psetName    = 'nanoaod_cfi.py'
config.JobType.maxMemoryMB = 3500
config.JobType.inputFiles  = ['run_in_container.sh', 'nanoaod_run.sh', 'Configuration', 'gridpack.tar.xz']
config.JobType.scriptExe   = 'run_in_container.sh'
config.JobType.scriptArgs  = [ 'events='+str(config.Data.unitsPerJob) ]
config.JobType.numCores    = 1

# set the storage site
config.Site.storageSite = 'T3_CH_CERNBOX'
