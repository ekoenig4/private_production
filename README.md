# Run3 Private Production

## Creating NanoAOD locally

```
cd HIG-Run3Summer22EE

# build simpack
# sh build_simpack /path/to/gridpack.tar type=(powheg, madgraph default) container=(cmssw-el8 default)
sh build_simpack.sh /path/to/gridpack.tar.gz powheg cmssw-el8
cd simulation/<gridpack>

# run wrapper script
# sh wrapper jobNum events type=(powheg, madgraph default)
sh wrapper.sh 1 10 powheg
```

