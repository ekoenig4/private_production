# Parameter set file used as input to cmsRun

# This is just a dummy because CRAB formally needs this file.
# It is ignored in practice; the actual script to be executed
# is defined in the CRAB config file using the JobType.scriptExe parameter.

# Despite the fact that it is a dummy,
# it seems to be needed to use the correct output file name,
# else CRAB will not collect the output files.
# 'Correct' meaning that it must correspond to the name
# specified in the last step of the crab_run.sh script.

import FWCore.ParameterSet.Config as cms

process = cms.Process('NANO')
process.source = cms.Source("EmptySource")
process.maxEvents = cms.untracked.PSet(input = cms.untracked.int32(-1))
process.output = cms.OutputModule("PoolOutputModule",
  fileName = cms.untracked.string('ntuple.root'))
process.out = cms.EndPath(process.output)
