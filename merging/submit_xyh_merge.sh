INPUT_PATH=/cmsuf/data/store/user/ekoenig/private-sample-production
INPUTS=(
    2024/mc/CRAB_PrivateMC/NMSSM_XToYH_YToHH_HToBB_MX_700_MY_400_2024
)

for INPUT in ${INPUTS[@]}; do
    newdir=${INPUT/CRAB_PrivateMC\//}
    echo sbatch hpg_merge.sbatch $INPUT_PATH/$INPUT $newdir
    sbatch hpg_merge.sbatch $INPUT_PATH/$INPUT $newdir
done