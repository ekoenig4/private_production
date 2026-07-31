#!/bin/bash

#SBATCH --account=avery
#SBATCH --qos=avery-b
#SBATCH --cpus-per-task=1
#SBATCH --mem=1G
#SBATCH --time=01:00:00

ls simpacks/*/crab_logs/* -d | xargs -P 32 -I {} sbatch -W crab_cmd.sh resubmit -d {}
