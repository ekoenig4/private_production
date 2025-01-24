# Gen-level checks of privately produced NanoGEN level files.

# The process of interest is H + cc (H not yet decayed).


import os
import sys
import numpy as np
import awkward as ak
from coffea.nanoevents import NanoEventsFactory, NanoAODSchema

import matplotlib.pyplot as plt

import argparse


if __name__=='__main__':

    # read command line arguments
    parser = argparse.ArgumentParser()
    parser.add_argument('-i', '--inputfile', required=True, type=os.path.abspath,
      help='Path to NanoAOD input file')
    args = parser.parse_args()
    print('Running check_hcc_nanogen.py with following configuration:')
    for arg in vars(args): print('  - {}: {}'.format(arg, getattr(args,arg)))

    # read input file
    events = NanoEventsFactory.from_root(
               {args.inputfile: 'Events'},
               schemaclass=NanoAODSchema).events()
    print('Number of events: {}'.format(ak.num(events.run.compute(), axis=0)))

    # get the genparticles and select H bosons
    # (based on PDGID and status codes)
    genparts = events.GenPart
    h = genparts[(genparts.pdgId==25) & (genparts.hasFlags(['isLastCopy']))]
    
    # print the number and mass of selected H bosons
    print('Number of selected H bosons:')
    print(ak.num(h.mass.compute()))
    print('H boson mass:')
    print(h.mass.compute())

    # find children of the selected H bosons
    h_children = h.children
    print('Pdg ID of H boson decay products:')
    print(h_children.pdgId.compute())

    # select c-quarks
    cquarks = genparts[(
      (genparts.pdgId==4)
      & (genparts.hasFlags(['isLastCopy']))
      & (genparts.hasFlags(['fromHardProcess']))
    )]
    cquarks = cquarks[(
      (cquarks.distinctParent.pdgId!=24)
      & (cquarks.distinctParent.pdgId!=23)
      & (cquarks.distinctParent.pdgId!=25)
    )]
    print('Number of selected c quarks:')
    print(ak.num(cquarks.pt.compute()))
    print('Number of events with 2 or more c quarks:')
    toomany = ak.num(cquarks[ak.num(cquarks.pt)>=2].pt.compute(), axis=0)
    print(toomany)
    print('Number of events with less than c quark:')
    print(ak.num(cquarks[ak.num(cquarks.pt)<1].pt.compute(), axis=0))

    # invesigate cases with more than 1 c-quark
    if toomany > 0:
        cquarks = cquarks[ak.num(cquarks.pt)>=2]
        num = ak.num(cquarks.pt.compute())
        parentPdgId = cquarks.parent.pdgId.compute()
        distinctParentPdgId = cquarks.distinctParent.pdgId.compute()
        distinctGrandParentPdgId = cquarks.distinctParent.distinctParent.pdgId.compute()
        status = cquarks.status.compute()
        statusFlags = cquarks.statusFlags.compute()
        isPrompt = cquarks.hasFlags(['isPrompt']).compute()
        fromHardProcess = cquarks.hasFlags(['fromHardProcess']).compute()
   
        for eventidx in range(len(num)):
            print('----- Event -----')
            print('Parent: {}'.format(parentPdgId[eventidx]))
            print('Distinct parent: {}'.format(distinctParentPdgId[eventidx]))
            print('Distinct grand-parent: {}'.format(distinctGrandParentPdgId[eventidx]))
            print('status: {}'.format(status[eventidx]))
            print('statusFlags: {}'.format(statusFlags[eventidx]))
            print('isPrompt: {}'.format(isPrompt[eventidx]))
            print('fromHardProcess: {}'.format(fromHardProcess[eventidx]))

    # select c-antiquarks
    cbarquarks = genparts[(
      (genparts.pdgId==-4)
      & (genparts.hasFlags(['isLastCopy']))
      & (genparts.hasFlags(['fromHardProcess']))
    )]
    cbarquarks = cbarquarks[(
      (cbarquarks.distinctParent.pdgId!=-24)
      & (cbarquarks.distinctParent.pdgId!=23)
      & (cbarquarks.distinctParent.pdgId!=25)
    )]
    print('Number of selected c antiquarks:')
    print(ak.num(cbarquarks.pt.compute()))
    print('Number of events with 2 or more c antiquarks:')
    toomany = ak.num(cbarquarks[ak.num(cbarquarks.pt)>=2].pt.compute(), axis=0)
    print(toomany)
    print('Number of events with less than c antiquark:')
    print(ak.num(cbarquarks[ak.num(cbarquarks.pt)<1].pt.compute(), axis=0))

    # invesigate cases with more than 1 c-quark
    if toomany > 0:
        cbarquarks = cbarquarks[ak.num(cbarquarks.pt)>=2]
        num = ak.num(cbarquarks.pt.compute())
        parentPdgId = cbarquarks.parent.pdgId.compute()
        distinctParentPdgId = cbarquarks.distinctParent.pdgId.compute()
        distinctGrandParentPdgId = cbarquarks.distinctParent.distinctParent.pdgId.compute()
        status = cbarquarks.status.compute()
        statusFlags = cbarquarks.statusFlags.compute()
        isPrompt = cbarquarks.hasFlags(['isPrompt']).compute()
        fromHardProcess = cbarquarks.hasFlags(['fromHardProcess']).compute()

        for eventidx in range(len(num)):
            print('----- Event -----')
            print('Parent: {}'.format(parentPdgId[eventidx]))
            print('Distinct parent: {}'.format(distinctParentPdgId[eventidx]))
            print('Distinct grand-parent: {}'.format(distinctGrandParentPdgId[eventidx]))
            print('status: {}'.format(status[eventidx]))
            print('statusFlags: {}'.format(statusFlags[eventidx]))
            print('isPrompt: {}'.format(isPrompt[eventidx]))
            print('fromHardProcess: {}'.format(fromHardProcess[eventidx]))    
