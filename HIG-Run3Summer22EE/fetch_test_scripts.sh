commands=(
    # https://cms-pdmv-prod.web.cern.ch/mcm/public/restapi/requests/get_test/HIG-Run3Summer22EEwmLHEGS-00282
    # https://cms-pdmv-prod.web.cern.ch/mcm/public/restapi/requests/get_test/HIG-Run3Summer22EEDRPremix-00223
    # https://cms-pdmv-prod.web.cern.ch/mcm/public/restapi/requests/get_test/HIG-Run3Summer22EEMiniAODv4-00213
    https://cms-pdmv-prod.web.cern.ch/mcm/public/restapi/requests/get_test/HIG-Run3Summer22EENanoAODv12-00213
)


setup() {
    echo "Fetching test script from $1"


    step=test/
    mkdir -p $step
    pushd $step

    script=$(basename $1)_fetch.sh
    if [ -f ${script}_1_cfg.py ]; then
        echo "Already fetched $1"
        return
    fi



    wget $1 -O $script

    echo "--------------------------------------------------"
    echo "Running $script"
    echo "--------------------------------------------------"
    
    chmod +x $script
    ./$script || exit $?
    popd
}


for cmd in "${commands[@]}"; do
    setup $cmd || exit $?
done