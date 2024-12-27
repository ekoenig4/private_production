#!/usr/bin/env python3

# Build the simpack


import os
import sys
import six
import argparse


if __name__=='__main__':

    # read command line arguments
    parser = argparse.ArgumentParser()
    parser.add_argument('-g', '--gridpack', required=True, type=os.path.abspath,
      help='Path to gridpack')
    parser.add_argument('-f', '--fragment', required=True, type=os.path.abspath,
      help='Path to generator fragment')
    parser.add_argument('-c', '--conditions', required=True, type=os.path.abspath,
      help='Path to folder with conditions (must contain "nanoaod_run.sh")')
    parser.add_argument('--container', default=None,
      help='Container to use (default: None)')
    parser.add_argument('-n', '--name', default=None,
      help='Name for the simpack (default: use gridpack name)')
    parser.add_argument('-o', '--outputdir', default='private-sample-production',
      help='CRAB setting: output base directory name for finished samples (NO full path, only base name!)'
           + ' (default: "private-sample-production")')
    parser.add_argument('--sample_name', default=None,
      help='CRAB setting: name for the sample (default: use gridpack name)')
    parser.add_argument('--events_per_job', default=-1, type=int,
      help='CRAB setting: number of events per job (default: leave unmodified wrt template)')
    parser.add_argument('--total_events', default=-1, type=int,
      help='CRAB setting: total number of events to generate (default: leave unmodified wrt template)')
    parser.add_argument('-s', '--site', default=None,
      help='CRAB setting: storage site (default: leave unmodified wrt template)')
    args = parser.parse_args()
    print('Running build_simpack.py with following configuration:')
    for arg in vars(args): print('  - {}: {}'.format(arg, getattr(args,arg)))

    # check command line args
    if not os.path.exists(args.gridpack):
        msg = 'Provided gridpack {} does not exist.'.format(args.gridpack)
        raise Exception(msg)
    if not os.path.exists(args.fragment):
        msg = 'Provided fragment {} does not exist.'.format(args.fragment)
        raise Exception(msg)
    if not os.path.exists(args.conditions):
        msg = 'Provided conditions folder {} does not exist.'.format(args.conditions)
        raise Exception(msg)
    required_condition_files = ['nanoaod_run.sh']
    for f in required_condition_files:
        if not os.path.exists(os.path.join(args.conditions, f)):
            msg = 'Provided conditions folder does not contain the required file {}.'.format(f)
            raise Exception(msg)
    if args.name is None:
        args.name = os.path.basename(args.gridpack).split('.')[0]
    if args.sample_name is None:
        args.sample_name = os.path.basename(args.gridpack).split('.')[0]

    # make path to full sample output directory
    # note: /store/user/<username> is automatically converted by CRAB
    #       to the correct path depending on the storage site.
    outputdir = '/store/user/{}'.format(os.getenv('USER'))
    outputdir = os.path.join(outputdir, args.outputdir)

    # make the simpacks folder if it does not yet exist
    if not os.path.exists('simpacks'): os.makedirs('simpacks')

    # handle the case where the requested simpack name already exists
    simpack = os.path.join('simpacks', args.name)
    if os.path.exists(simpack):
        msg = 'WARNING: requested simpack {} already exists in simpacks.'.format(args.name)
        msg += ' Remove and continue? (y/n)'
        print(msg)
        go = six.moves.input()
        if go!='y': sys.exit()
        os.system('rm -r {}'.format(simpack))
    os.makedirs(simpack)

    # copy the gridpack to the simpack
    newgridpack = os.path.join(simpack, 'gridpack.tar.xz')
    print('Copying gridpack...')
    os.system('cp -v {} {}'.format(args.gridpack, newgridpack))

    # copy the templates to the simpack
    templates = os.path.abspath('../templates')
    print('Copyting templates...')
    os.system('cp -rv {} {}'.format(os.path.join(templates,'*'), simpack))

    # copy the generator fragment to the simpack
    newfragment = os.path.join(simpack, 'Configuration/GenProduction/python/fragment.py')
    os.makedirs(os.path.dirname(newfragment))
    print('Copying generator fragment...')
    os.system('cp -v {} {}'.format(args.fragment, newfragment))

    # copy the condition dependent exe to the simpack
    print('Copyting condition dependent exe...')
    os.system('cp -rv {} {}'.format(os.path.join(args.conditions,'*'), simpack))

    # make sure the nanoaod_run script is executable
    os.system('chmod +x {}'.format(os.path.join(simpack, 'nanoaod_run.sh')))

    # patch the run_in_container script
    containerscript = os.path.join(simpack, 'run_in_container.sh')
    print('Patching run_in_container.sh...')
    if args.container is not None:
        os.system("sed -i 's/$CONTAINER/{}/' {}".format(args.container, containerscript))
    else:
        os.system("sed -i 's/$CONTAINER --command-to-run/bash/' {}".format(containerscript))

    # patch the crab configuration file
    crabconfigfile = os.path.join(simpack, 'crab_config.py')
    patches = []
    # output directory
    outputdir = outputdir.replace('/', '\/')
    patches.append("sed -i 's/config.Data.outLFNDirBase .*/config.Data.outLFNDirBase = \"{}\"/' {}".format(outputdir, crabconfigfile))
    # work area subfolder (requestName)
    patches.append("sed -i 's/config.General.requestName .*/config.General.requestName = \"{}\"/' {}".format(args.name, crabconfigfile))
    # sample name (outputDatasetTag)    
    patches.append("sed -i 's/config.Data.outputDatasetTag .*/config.Data.outputDatasetTag = \"{}\"/' {}".format(args.sample_name, crabconfigfile))
    # number of jobs and events
    if args.events_per_job > 0:
        patches.append("sed -i 's/config.Data.unitsPerJob .*/config.Data.unitsPerJob = {}/' {}".format(args.events_per_job, crabconfigfile))
    if args.total_events > 0:
        patches.append("sed -i 's/config.Data.totalUnits .*/config.Data.totalUnits = {}/' {}".format(args.total_events, crabconfigfile))
    # storage site
    if args.site is not None:
        patches.append("sed -i 's/config.Site.storageSite .*/config.Site.storageSite = \"{}\"/' {}".format(args.site, crabconfigfile))
    print('Patching the crab_config.py...')
    for patch in patches: os.system(patch)
