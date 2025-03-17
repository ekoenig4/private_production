from CRABClient.UserUtilities import config

config = config()

# set the CRAB working directory (where log files will appear)
config.General.workArea        = 'crab_logs'
# set the folder within the CRAB working directory for a specific submission
config.General.requestName     = '{requestName}'
config.General.transferOutputs = True
config.General.transferLogs    = False

config.Data.splitting   = 'EventBased'
# set the number of events per job
config.Data.unitsPerJob = {unitsPerJob}
# set the total number of events
# (the number of jobs will be totalUnits/unitsPerJob)
config.Data.totalUnits  = {totalUnits}
# set the output directory
# note that /store/user/<username> is automatically translated by CRAB
# to a physical file location, depending on the storage site.
# for example using site T3_CH_CERNBOX, this path translates to
# /eos/user/<initial>/<username>
config.Data.outLFNDirBase = '{outLFNDirBase}'
config.Data.publication = False
# set the name of the sample
config.Data.outputDatasetTag = '{outputDatasetTag}'

# set the plugin name (do not change, only 'privateMC' is allowed for this type of job)
config.JobType.pluginName  = 'PrivateMC'
# set the parameter set file (do not change, it is only a dummy, formally needed by CRAB)
config.JobType.psetName    = 'pset.py'
# set the requested memory limit
config.JobType.maxMemoryMB = 5000
# set the auxiliary files and folders that should be copied to the worker node.
# note: the *.txt can hold any auxiliary files in txt format present in the simpack.
config.JobType.inputFiles  = ['run_in_container.sh', 'nanoaod_run.sh', 'Configuration', 'gridpack.tar.xz', '*.txt']
# set the actual executabe that will be run
# (note: this overrides the default 'cmsRun pset.py')
config.JobType.scriptExe   = 'run_in_container.sh'
config.JobType.scriptArgs  = [ 'events='+str(config.Data.unitsPerJob) ]
# set the number of requested cores
config.JobType.numCores    = 1

# set the storage site
config.Site.storageSite = '{storageSite}'
