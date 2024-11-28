# Run3 Private Production

## Creating NanoAOD locally

```
cd HIG-Run3Summer22EE

# build simpack
# sh build_simpack /path/to/gridpack.tar type=(powheg, madgraph default) container=(cmssw-el8 default)
sh build_simpack.sh /path/to/gridpack.tar.gz powheg cmssw-el8
cd simulation/<gridpack>

# run wrapper script
# sh wrapper jobNum events type=(powheg, madgraph default)
sh wrapper.sh 1 10 powheg
```

## Submitting NanoAOD to CRAB

### Edit CRAB configuration
The `crabConfig.py` file is written on the fly inside `build_simpack.sh`. 
Openning up `build_simpack.sh` and scrolling to the bottom reveals the config. 
Some options that may need to be updated
```
# specify the number of crab jobs
# NOTE if you want more events increse the number of jobs
config.Data.unitsPerJob = 10
# the number of events per crab job (keep this below 500 events)
config.Data.totalUnits  = 10*10

# specify the storage path for the output files
# NOTE this needs to be a path that you have permission to write to
config.Data.outLFNDirBase = '/store/user/ekoenig/private_production/HIG-Run3Summer22EE/'

# specify the requested memory for the job
# The more config.Data.totalUnits you request the larger this number needs to be
# NOTE try to keep this number < 3500 MB otherwise your jobs may not run 
config.JobType.maxMemoryMB = 3500

# specify the storage site, this defaults to CERNBOX
# you can find other storage site names online
config.Site.storageSite = 'T3_CH_CERNBOX'
```

### Submitting to CRAB
You will need to setup the CMSSW environment for the final stage of production as well as source the proper crab environment.
There is a provided script which does this all for you, `submit_crab.sh`. 
Workflow for submitting crab given a new gridpack
```
cd HIG-Run3Summer22EE

# build simpack
# sh build_simpack /path/to/gridpack.tar type=(powheg, madgraph default) container=(cmssw-el8 default)
sh build_simpack.sh /path/to/gridpack.tar.gz powheg cmssw-el8
cd simulation/<gridpack>

bash submit_crab.sh
```

If submission is successful there will be a new directory created for the crab job.
There is a provided script which can fetch the status of your job.
```
bash crab_status.sh -d {crab_job}/{crab_id}
```
