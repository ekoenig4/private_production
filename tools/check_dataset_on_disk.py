#!/bin/env python3

import os
import sys
import das_client


if __name__=='__main__':

    # read the dataset to query as command line arg
    dataset = sys.argv[1]

    # find blocks in dataset
    dasquery = 'block dataset={}'.format(dataset)
    blocks = das_client.get_data(dasquery)
    if blocks['status'] != 'ok': raise Exception(str(blocks))
    blocks = blocks['data']
    blocks = [el['block'][0]['name'] for el in blocks]
    print('Found {} blocks in dataset.'.format(len(blocks)))

    # limit number of blocks (for testing or speeed)
    nblocks = 20
    blocks = blocks[:nblocks]
    print('Limiting number of blocks to {}.'.format(nblocks))
    
    # loop over blocks
    blocks_to_sites = {}
    for blockidx, block in enumerate(blocks):
        print('Now processing block {}/{}...'.format(blockidx+1, len(blocks)), end='\r')

        # find sites for block
        dasquery = 'site block={}'.format(block)
        sites = das_client.get_data(dasquery)
        if sites['status'] != 'ok': raise Exception(str(sites))
        sites = sites['data']
        sites = [el['site'][0]['name'] for el in sites]
        sites = list(set(sites))
        blocks_to_sites[block] = sites

    # get blocks with T2 disk access
    blocks_on_disk = []
    for block in blocks:
        sites = blocks_to_sites[block]
        disk = False
        for site in sites:
            if site.startswith('T2') and not site.endswith('Tape'): disk = True
        if disk: blocks_on_disk.append(block)

    # print results
    msg = '{} out of {} blocks are found to be on disk.'.format(len(blocks_on_disk), len(blocks))
    print(msg)
    nprint = 10
    print('Printing first {}:'.format(nprint))
    print(blocks_on_disk[:nprint])
