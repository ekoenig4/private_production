#!/bin/env python3

#########################################
# Kill all CRAB jobs for given simpacks #
#########################################

import os
import sys
import glob
import argparse


if __name__ == '__main__':

    # read command line arguments
    parser = argparse.ArgumentParser()
    parser.add_argument('-i', '--simpackdir', required=True, type=os.path.abspath,
      help='Simpack directory')
    args = parser.parse_args()

    # check command line arguments
    if not os.path.isdir(args.simpackdir):
        raise Exception('ERROR: simpack directory {} does not exist'.format(args.simpackdir))

    # find all sample folders
    # (note: this is any folder inside a 'crab_logs' folder somewhere inside the simpack dir)
    fproc = sorted(glob.glob(os.path.join(args.simpackdir,'**/crab_logs/*'), recursive=True))
    nfproc = len(fproc)
    if nfproc == 0:
        msg = 'No samples found in provided simpack dir; exiting.'
        raise Exception(msg)

    # find the crab_command script for each sample
    # (note: cannot use standard 'crab kill' command since a special container is needed)
    # (note: absolute path does not work, script must be run from inside its directory)
    cmds = []
    thisdir = os.path.abspath(os.path.dirname(__file__))
    for fidx, f in enumerate(fproc):
        workdir = f.split('/crab_logs/')[0]
        exe = os.path.join(workdir, 'crab_command.sh')
        if not os.path.exists(exe):
            msg = 'Could not find crab_command.sh script at location {}'.format(exe)
            msg += 'for sample {}.'.format(f)
            raise Exception(msg)
        cmd = 'cd {}'.format(workdir)
        cmd += '; bash crab_command.sh kill {}'.format(f)
        cmds.append(cmd)

    # loop over samples
    for fidx, f in enumerate(fproc):
        print('Now processing sample {} of {}'.format(fidx+1,len(fproc)))
        print('({})'.format(f))

        # get and run appropriate command to execute
        kill_cmd = cmds[fidx]
        os.system(kill_cmd)
