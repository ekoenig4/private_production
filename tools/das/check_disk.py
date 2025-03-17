#!/bin/env python3

import os
import sys
import argparse

from tqdm import tqdm
import das_client

sys.path.append(os.path.abspath('../../jobtools'))
import condortools as ct


if __name__=='__main__':

    # read command line arguments
    parser = argparse.ArgumentParser()
    parser.add_argument('-d', '--dataset', required=True,
      help='Dataset name as shown on DAS')
    parser.add_argument('-l', '--level', default='file', choices=['file', 'block'],
      help='Choose the level of the output (either "file" or "file")')
    parser.add_argument('-n', '--number', default=-1, type=int,
      help='Limit number of files/blocks to process (for speed) (default: no limit)')
    parser.add_argument('-o', '--outputfile', default=None,
      help='Define output file (default: no file, just print to screen)')
    parser.add_argument('-r', '--runmode', default='local', choices=['local', 'condor'],
      help='Choose run mode (either "local" or "condor")')
    parser.add_argument('-p', '--proxy', default=None, type=os.path.abspath,
      help='Set path to proxy (might be needed in condor submission mode;'
          +' first copy your proxy  to somewhere else than /tmp)')
    parser.add_argument('--shortcut', default=False, action='store_true',
      help='Use shortcut by checking disk availability per block,'
          +' but write out individual files for available blocks.'
          +' This assumes that file presence is managed per-block,'
          +' which seems to be the case for a few examples, but is not guaranteed.'
          +' Note that this argument overrides the --level argument.')
    args = parser.parse_args()

    # handle condor submission
    if args.runmode=='condor':
        cmd = 'python3 check_disk.py'
        cmd += ' -d {}'.format(args.dataset)
        cmd += ' -l {}'.format(args.level)
        if args.number > 0: cmd += ' -n {}'.format(args.number)
        if args.outputfile is not None: cmd += ' -o {}'.format(args.outputfile)
        cmd += ' -r local'
        if args.shortcut: cmd += ' --shortcut'
        ct.submitCommandAsCondorJob('cjob_check_disk', cmd, proxy=args.proxy, jobflavour='workday')
        sys.exit()

    # handle shortcut case
    if args.shortcut: args.level = 'block'

    # find files (or blocks) in dataset
    dasquery = '{} dataset={}'.format(args.level, args.dataset)
    files = das_client.get_data(dasquery)
    if files['status'] != 'ok': raise Exception(str(files))
    files = files['data']
    files = [el[args.level][0]['name'] for el in files]
    print('Found {} {}s in dataset.'.format(len(files), args.level))

    # limit number of files (or blocks) (for testing or speeed)
    if args.number > 0 and args.number < len(files):
        files = files[:args.number]
        print('Limiting number of {}s to {}.'.format(args.level, args.number))

    # define log file for writing progress
    logfile = 'log_' + os.path.splitext(os.path.basename(args.outputfile))[0] + '.txt'

    import concurrent.futures

    def find_sites(file):
        dasquery = 'site {}={}'.format(args.level, file)
        sites = das_client.get_data(dasquery)
        if sites['status'] != 'ok':
            raise Exception(str(sites))
        sites = sites['data']
        sites = [el['site'][0]['name'] for el in sites]
        return file, list(set(sites))

    # loop over files with multithreading
    files_to_sites = {}
    with concurrent.futures.ThreadPoolExecutor(max_workers=24) as executor:
        results = list(tqdm(executor.map(find_sites, files), total=len(files), desc='Finding sites for {}s'.format(args.level)))
    
    for file, sites in results:
        files_to_sites[file] = sites

    # get files with disk access
    # (either T1 ending on 'Disk' or any T2;
    #  also double check by veto ending in 'Tape')
    files_on_disk = []
    for file in files:
        sites = files_to_sites[file]
        disk = False
        for site in sites:
            if site.startswith('T1') and site.endswith('Disk'): disk = True
            if site.startswith('T2') and not site.endswith('Tape'): disk = True
        if disk: files_on_disk.append(file)

    # print results
    msg = '{} out of {} {}s are found to be on disk.'.format(len(files_on_disk), len(files), args.level)
    print(msg)
    nprint = 10
    print('Printing first {}:'.format(nprint))
    print(files_on_disk[:nprint])

    # handle shortcut case
    if args.shortcut:
        blocks_on_disk = files_on_disk[:]
        files_on_disk = []

        # loop over blocks
        for blockidx, block in enumerate(blocks_on_disk):
            
            # write progress to screen and to a log file
            if blockidx < 10 or (blockidx+1) % step == 0:
                msg = 'Finding files in block {}/{}...'.format(blockidx+1, len(blocks_on_disk))
                print(msg, end='\r')
                with open(logfile,'a') as f: f.write(msg + '\n')

            # find files in block
            dasquery = 'file block={}'.format(block)
            files = das_client.get_data(dasquery)
            if files['status'] != 'ok': raise Exception(str(files))
            files = files['data']
            files = [el['file'][0]['name'] for el in files]
            files_on_disk += files

    # write output file
    if args.outputfile is not None:
        with open(args.outputfile, 'w') as f:
            for file_on_disk in files_on_disk:
                f.write(file_on_disk + '\n')
        # post-processing
        tmpfile = os.path.splitext(os.path.basename(args.outputfile))[0] + '_tmp.txt'
        os.system('sort {} > {}'.format(args.outputfile, tmpfile))
        os.system('uniq {} > {}'.format(tmpfile, args.outputfile))
        os.system('rm {}'.format(tmpfile))
        print('Output written to {}'.format(args.outputfile))

    # delete temporary log file
    if os.path.exists(logfile): os.system('rm {}'.format(logfile))
