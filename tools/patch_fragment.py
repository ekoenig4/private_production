import os
import sys


def find_line_with_closing_bracket(lines, start_idx):
    stop_idx = start_idx
    total_open = lines[start_idx].count('(')
    total_close = lines[stop_idx].count(')')
    while total_close < total_open and stop_idx < len(lines)-1:
        stop_idx += 1
        total_open += lines[stop_idx].count('(')
        total_close += lines[stop_idx].count(')')
    if total_close < total_open:
        msg = 'Reached end of lines without closing bracket.'
        raise Exception(msg)
    return stop_idx
    
def patch_fragment(fragment):
    with open(fragment, 'r') as f:
        lines = f.readlines()
    newlines = patch_fragment_lines(lines)
    with open(fragment, 'w') as f:
        for line in newlines: f.write(line)

def patch_fragment_lines(lines):

    # find start index of externalLHEProducer block
    start_idx = [idx for idx, line in enumerate(lines) if 'externalLHEProducer' in line]
    if len(start_idx)==0:
        msg = 'Automatic patching of generator fragment failed:'
        msg += ' found no lines corresponding to externalLHEProducer.'
        msg += ' Please fix the fragment manually.'
        raise Exception(msg)
    if len(start_idx)>1:
        msg = 'Automatic patching of generator fragment failed:'
        msg += ' found multiple lines corresponding to externalLHEProducer.'
        msg += ' Please fix the fragment manually.'
        raise Exception(msg)
    start_idx = start_idx[0]

    # find stop index of exteralLHEProducer block
    stop_idx = find_line_with_closing_bracket(lines, start_idx)
    offset = start_idx
    producer_lines = lines[start_idx:stop_idx+1]

    # find start index of args to externalLHEProducer block
    start_idx = [idx for idx, line in enumerate(producer_lines) if line.strip(' \t').startswith('args')]
    if len(start_idx)==0:
        msg = 'Automatic patching of generator fragment failed:'
        msg += ' found no lines corresponding to externalLHEProducer args.'
        msg += ' Please fix the fragment manually.'
        raise Exception(msg)
    if len(start_idx)>1:
        msg = 'Automatic patching of generator fragment failed:'
        msg += ' found multiple lines corresponding to externalLHEProducer args.'
        msg += ' Please fix the fragment manually.'
        raise Exception(msg)
    start_idx = start_idx[0]

    # find stop index of args to externalLHEProducer block
    stop_idx = find_line_with_closing_bracket(producer_lines, start_idx)

    # insert the patch in the right place
    cut_start = offset + start_idx
    cut_stop = offset + stop_idx + 1
    imports = ([
      "import os\n"
    ])
    patch = ([
      "  args = cms.vstring(os.path.join(os.environ['PWD'], 'gridpack.tar.xz')),\n"
    ])
    newlines = imports + lines[:cut_start] + patch + lines[cut_stop:]
    return newlines
