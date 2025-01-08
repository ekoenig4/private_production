# Processing sequence for NanoGen format

This sequence produces GEN-level information only (but still in the NanoAOD format).
No detector simulation or RECO-level particle reconstruction is performed.
As a consequence, this sequence does not depend on the data-taking year (which might affect the detector but not the laws of physics).
As another consequence, it is much faster than producing full samples and can be used for quick GEN-level studies.

More information on the NanoGen format, as well as the correct processing sequence,
can be retrieved from [this TWiki](https://twiki.cern.ch/twiki/bin/view/CMS/NanoGen).
