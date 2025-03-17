# Merge the output of NanoAOD production


import os
import sys
import six
import glob
import argparse
sys.path.append(os.path.abspath('../jobtools'))
import condortools as ct


def print_iostruct(iostruct):
    for key,val in iostruct.items():
        print(key)
        for el in val: print('  - {}'.format(el))


if __name__=='__main__':

    # read command line arguments
    parser = argparse.ArgumentParser()
    parser.add_argument('-s', '--sample', required=True, type=os.path.abspath,
      help='Path to sample (i.e. CRAB output directory for this sample)')
    parser.add_argument('-o', '--outputdir', required=True, type=os.path.abspath,
      help='Path to output directory where to store the merged sample')
    parser.add_argument('-g', '--group', default=-1, type=int,
      help='Group size of files to merge (default: merge all files into 1)')
    parser.add_argument('--cmssw', default=None,
      help='Path to CMSSW installation to do cmsenv (needed for haddnano.py)'
          +' (choose an intallation compatible with current el9 lxplus architecture, e.g. 14+)')
    parser.add_argument('-r', '--runmode', default='condor', choices=['condor','local'],
      help='Run in condor job or locally in the terminal')
    parser.add_argument('--no-replace', action='store_true', default=False,
                        help='Exit if output directory already exists')
    args = parser.parse_args()
    print('Running merge.py with following configuration:')
    for arg in vars(args): print('  - {}: {}'.format(arg, getattr(args,arg)))

    # check command line args
    if not os.path.exists(args.sample):
        msg = 'Provided sample {} does not exist.'.format(args.sample)
        raise Exception(msg)
    cmssw = os.path.abspath(args.cmssw) if args.cmssw is not None else None
    if cmssw is not None:
        if not os.path.exists(cmssw):
            msg = 'Provided CMSSW installation {} does not exist.'.format(cmssw)
            raise Exception(msg)

    # find all files in this sample
    pattern = os.path.join(args.sample, '**', 'ntuple_*.root')
    files = sorted(glob.glob(pattern, recursive=True))
    print('Found {} files for this sample.'.format(len(files)))

    # group files to merge
    iostruct = {}
    if args.group <= 0: iostruct['ntuple_merged.root'] = files
    else:
        fidx = 0
        gidx = 1
        while fidx<len(files):
            oname = 'ntuple_merged_{}.root'.format(gidx)
            ilist = files[fidx:fidx+args.group]
            iostruct[oname] = ilist
            fidx += args.group
            gidx += 1
        msg = 'Merging {} files in groups of {}'.format(len(files), args.group)
        msg += ' will result in {} merged files.'.format(len(iostruct.keys()))
        print(msg)

    # manage output directory
    if os.path.exists(args.outputdir):
        msg = 'WARNING: output directory {} already exists'.format(args.outputdir)
        msg += ', clean it? (y/n)'
        print(msg)

        if args.no_replace: sys.exit()

        go = six.moves.input()
        if go!='y': sys.exit()
        os.system('rm -r {}'.format(args.outputdir))
    os.makedirs(args.outputdir)

    import luigi
    class cjob_merge(luigi.Task):
        outputfile = luigi.Parameter()
        inputfiles = luigi.ListParameter()
        cmssw = luigi.Parameter()

        def haddnano(self):
            # make the haddnano command
            haddnano = 'haddnano.py'
            haddnano += ' {}'.format(os.path.join(args.outputdir, self.outputfile))
            for f in self.inputfiles: haddnano += ' {}'.format(f)

            return haddnano

        def local(self):
            cmd = self.haddnano()

            if self.cmssw:
                cmd = f'cd {self.cmssw}; cmsenv; {cmd}'

            os.system(cmd)

        def condor(self):
            # make self.task_id directory

            os.makedirs(f'jobs/{self.task_id}', exist_ok=True)
            ct.submitCommandAsCondorJob(f'jobs/{self.task_id}/submit', self.haddnano(), cmssw_version=self.cmssw)


    # loop over groups
    commands = [
        cjob_merge(outputfile, inputfiles, cmssw)
        for outputfile, inputfiles in iostruct.items()
    ]
    
    from tqdm import tqdm
    # run the command
    if args.runmode=='local':
        for cmd in tqdm(commands, desc='Running merge'):
            cmd.local()

    elif args.runmode=='condor': 
        import concurrent.futures as cf

        with cf.ThreadPoolExecutor(max_workers=None) as executor:
            futures = [executor.submit(cmd.condor) for cmd in commands]
            for future in tqdm(cf.as_completed(futures), total=len(futures), desc='Running merge'):
                future.result()

