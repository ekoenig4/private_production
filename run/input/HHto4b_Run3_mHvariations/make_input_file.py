import os
import sys
import six
import argparse


if __name__=='__main__':

    # read command line arguments
    parser = argparse.ArgumentParser()
    parser.add_argument('-m', '--masses', required=True, nargs='+')
    parser.add_argument('-y', '--years', required=True, nargs='+',
      choices=['2022-preEE', '2022-postEE', '2023-preBPIX', '2023-postBPIX'])
    args = parser.parse_args()

    # loop over masses and years
    lines = []
    for mass in args.masses:
        for year in args.years:
            # set gridpack, fragment and conditions
            gridpack = '/afs/cern.ch/user/l/llambrec/gridpack-storage/HH-m-{}/'.format(mass)
            gridpack += 'ggHH_slc7_amd64_gcc700_CMSSW_10_6_8_workdir_powheg_ggHH_SM_m_{}.tgz'.format(mass)
            fragment = os.path.abspath('../../../genfragments/HHto4b_powheg')
            fragment = os.path.join(fragment, 'HHto4b_mH_{}_powheg.py'.format(mass))
            conditions = os.path.abspath('../../../conditions-{}'.format(year))
            # make sample name
            name = 'HHto4b_mH_{}_powheg_pythia8_Run3_{}'.format(mass, year)
            line = ' '.join([name, gridpack, fragment, conditions])
            lines.append(line)

    # existence check
    for line in lines:
        parts = line.split(' ')
        for part in parts[1:]:
            if not os.path.exists(part):
                msg = '{} does not seem to exist.'.format(part)
                raise Exception(msg)

    # make input file
    filename = 'HHto4b_Run3_mHvariations.txt'
    with open(filename, 'w') as f:
        for line in lines: f.write(line + '\n')
