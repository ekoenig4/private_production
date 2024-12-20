
if [ -z $BASE ]; then
    BASE=runcmsgrid
fi

GRIDPACK=$1
if [ -z $GRIDPACK ]; then
    echo "Usage: $0 <gridpack.tar.xz>"
    exit 1
fi

if [ ! -f $GRIDPACK ]; then
    echo "Gridpack $GRIDPACK not found"
    exit 1
fi

EXTENSIONS=(tar.gz tgz tar.xz)
# try extensions (.tar.gz, .tgz)
for ext in ${EXTENSIONS[@]}; do
    if [[ $GRIDPACK == *.$ext ]]; then
        SIMPACK=$(basename $GRIDPACK .$ext)
        EXTENSION=$ext
        break
    fi
done

if [ -z $SIMPACK ]; then
    echo "Gridpack extension not recognized"
    exit 1
fi


echo "Unpacking gridpack $SIMPACK"
mkdir -p $BASE/$SIMPACK
cp -v $GRIDPACK $BASE/$SIMPACK/gridpack.$EXTENSION

cd $BASE/$SIMPACK
tar zxvf gridpack.$EXTENSION
