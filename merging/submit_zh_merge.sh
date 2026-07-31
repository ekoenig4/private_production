INPUT_PATH=/cmsuf/data/store/user/ekoenig/private-sample-production
INPUTS=(
    2022/mc/CRAB_PrivateMC/ZH_ZToBB_HToBB_M-125_2022-postEE
    2023/mc/CRAB_PrivateMC/ZH_ZToBB_HToBB_M-125_2023-preBPIX
    2021/mc/CRAB_PrivateMC/ZH_ZToBB_HToBB_M-125_2022-preEE
    2020/mc/CRAB_PrivateMC/ZH_ZToBB_HToBB_M-125_2023-postBPIX
    2022/mc/CRAB_PrivateMC/ggZH_HToBB_ZToBB_M-125_2022-postEE
    2023/mc/CRAB_PrivateMC/ggZH_HToBB_ZToBB_M-125_2023-preBPIX
    2021/mc/CRAB_PrivateMC/ggZH_HToBB_ZToBB_M-125_2022-preEE
    2020/mc/CRAB_PrivateMC/ggZH_HToBB_ZToBB_M-125_2023-postBPIX
)

for INPUT in ${INPUTS[@]}; do
    newdir=${INPUT/CRAB_PrivateMC\//}
    echo sbatch hpg_merge.sbatch $INPUT_PATH/$INPUT $newdir
    sbatch hpg_merge.sbatch $INPUT_PATH/$INPUT $newdir
done