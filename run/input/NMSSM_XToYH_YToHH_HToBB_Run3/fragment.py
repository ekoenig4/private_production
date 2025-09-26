
import FWCore.ParameterSet.Config as cms

# link to cards:
# https://github.com/cms-sw/genproductions/tree/master/bin/MadGraph5_aMCatNLO/cards/production/2017/13TeV/NMSSM_XYH_YToHH_MX_1200_MY_500
import os
externalLHEProducer = cms.EDProducer('ExternalLHEProducer',
    args = cms.vstring(os.path.join(
    os.environ['PWD'], 
    'gridpack.tar.xz'
    )),
    nEvents = cms.untracked.uint32(5000),
    numberOfParameters = cms.uint32(1),
    outputFile = cms.string('cmsgrid_final.lhe'),
    generateConcurrently = cms.untracked.bool(True),
    scriptName = cms.FileInPath('GeneratorInterface/LHEInterface/data/run_generic_tarball_cvmfs.sh')
)


from Configuration.Generator.Pythia8CommonSettings_cfi import *
from Configuration.Generator.MCTunesRun3ECM13p6TeV.PythiaCP5Settings_cfi import *
from Configuration.Generator.PSweightsPythia.PythiaPSweightsSettings_cfi import *

generator = cms.EDFilter("Pythia8ConcurrentHadronizerFilter",
                         maxEventsToPrint = cms.untracked.int32(1),
                         pythiaPylistVerbosity = cms.untracked.int32(1),
                         filterEfficiency = cms.untracked.double(1.0),
                         pythiaHepMCVerbosity = cms.untracked.bool(False),
                         comEnergy = cms.double(13600.),
                         PythiaParameters = cms.PSet(
                             pythia8CommonSettingsBlock,
                             pythia8CP5SettingsBlock,
                             pythia8PSweightsSettingsBlock,
                             processParameters = cms.vstring(
                              
    '25:onMode = off',
    '25:onIfMatch = 5 -5',
    'ResonanceDecayFilter:filter = on'

                             ),
                             parameterSets = cms.vstring('pythia8CommonSettings',
                                                         'pythia8CP5Settings',
                                                         'pythia8PSweightsSettings',
                                                         'processParameters'
                                                     )
                         )
)
ProductionFilterSequence = cms.Sequence(generator)
