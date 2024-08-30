BASE=simulation
TEMPLATE=Template

GRIDPACK=$1
SIMPACK=$BASE/$(basename $GRIDPACK .tar.xz)

echo "Building simulation package $SIMPACK"
mkdir -p $SIMPACK
cp -v $GRIDPACK $SIMPACK/gridpack.tar.xz
cp -rv $TEMPLATE/* $SIMPACK