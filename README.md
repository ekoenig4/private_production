# Run3 Private Production

## Creating NanoAOD locally

```
cd HIG-Run3Summer22EE
sh build_simpack.sh /path/to/gridpack.tar.gz
cd simulation/$(basename gridpack.tar.gz .tar.gz)
sh scriptExe.sh 1 10
```

