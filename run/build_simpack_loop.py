#!/usr/bin/env python3

# Build and submit simpacks in a loop


import os
import sys
import six
import argparse


if __name__=='__main__':

    # read command line arguments
    parser = argparse.ArgumentParser()
    parser.add_argument('-i', '--inputfile', required=True, type=os.path.abspath,
      help='Path to input file, containing gridpacks, genfragments and conditions')
    parser.add_argument('--container', default=None,
      help='Container to use (default: None)')
    parser.add_argument('-o', '--outputdir', default='private-sample-production',
      help='CRAB setting: output base directory name for finished samples (NO full path, only base name!)'
           + ' (default: "private-sample-production")')
    parser.add_argument('--name_suffix', default=None,
      help='Extra suffix to append to every sample name (e.g. to distinguish different production runs)')
    parser.add_argument('--events_per_job', default=-1, type=int,
      help='CRAB setting: number of events per job (default: leave unmodified wrt template)')
    parser.add_argument('--total_events', default=-1, type=int,
      help='CRAB setting: total number of events to generate per sample (default: leave unmodified wrt template)')
    parser.add_argument('-s', '--site', default=None,
      help='CRAB setting: storage site (default: leave unmodified wrt template)')
    args = parser.parse_args()
    print('Running build_simpack_loop.py with following configuration:')
    for arg in vars(args): print('  - {}: {}'.format(arg, getattr(args,arg)))

    # handle case where simpacks were already built, now just submit
    if os.path.isdir(args.inputfile):
        # find simpacks in provided directory
        simpacks = [os.path.join(args.inputfile, simpack) for simpack in os.listdir(args.inputfile)]
        msg = 'Submit {} simpacks in {}? (y/n)'.format(len(simpacks), args.inputfile)
        print(msg)
        go = six.moves.input()
        if go != 'y': sys.exit()
        for simpack in simpacks:
            cmd = 'cd {}; ./crab_submit.sh'.format(simpack)
            os.system(cmd)
        sys.exit()

    # read input file
    with open(args.inputfile, 'r') as f: lines = f.readlines()
    simpacks = []
    for line in lines:
        line = line.strip(' \t\n')
        if line.startswith('#'): continue
        lineparts = line.split(' ')
        if len(lineparts) != 4: raise Exception('Input file could not be read.')
        name = lineparts[0]
        if args.name_suffix is not None: name += '_{}'.format(args.name_suffix)
        simpacks.append({'name': name, 'gridpack': lineparts[1], 'fragment': lineparts[2], 'conditions': lineparts[3]})
    print('Found {} simpacks to create.'.format(len(simpacks)))

    # make all simpacks
    for simpack in simpacks:
        # make build_simpack command
        cmd = 'python3 build_simpack.py'
        cmd += ' -g {}'.format(simpack['gridpack'])
        cmd += ' -f {}'.format(simpack['fragment'])
        cmd += ' -c {}'.format(simpack['conditions'])
        cmd += ' -n {}'.format(simpack['name'])
        cmd += ' --sample_name {}'.format(simpack['name'])
        cmd += ' -o {}'.format(args.outputdir)
        if args.container is not None: cmd += ' --container {}'.format(args.container)
        if args.events_per_job > 0: cmd += ' --events_per_job {}'.format(args.events_per_job)
        if args.total_events > 0: cmd += ' --total_events {}'.format(args.total_events)
        if args.site is not None: cmd += ' --site {}'.format(args.site)
        # run the command
        os.system(cmd)

    # ask for confirmation
    msg = 'Ready to submit {} simpacks. Continue? (y/n)'.format(len(simpacks))
    print(msg)
    go = six.moves.input()
    if go != 'y': sys.exit()

    # submit all simpacks
    for simpack in simpacks:
        simpackdir = os.path.abspath(os.path.join('simpacks', simpack['name']))
        cmd = 'cd {}; ./crab_submit.sh'.format(simpackdir)
        os.system(cmd)
