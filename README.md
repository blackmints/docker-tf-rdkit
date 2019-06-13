# Docker image for latest tensorflow-gpu and RDKit
Docker image for tensorflow-gpu with RDKit.
As RDKit does not provide pip repository for installation on virtualenv, this is a docker image for rdkit with tensorflow-gpu. By building rdkit from the source inside docker, rdkit packages are obtained and transferred to working docker image.

### Core intentions
- Use latest tensorflow-gpu (=1.13.1)
- Use latest rdkit (=2019.03.2)

### Key Changes
- Upgrading rdkit version from 2018.09 to 2019.03.2 additionally requires *libboost-iostreams*.
- Changing the python verion PYTHON_INCLUDE_DIR=/usr/include/python3.5 to other breaks the build.
- Executing rdkit requires boost 1.62.0, however tensorflow/tensorflow:latest-gpu-py3 is built over ubuntu xenial. When apt-get install libboost, it installs 1.58.0 rather than 1.62.0. Therefore, I used personal PPA to obtain 1.62.0 for xenial, which is *ppa:bkryza/onedata-deps-gcc7*.
- When executed, libstdc++.so.6: version 'GLIBCXX_3.4.22' not found occurs. It is fixed by adding additional *ppa:ubuntu-toolchain-r/test* and installation of gcc-4.9, libstdc++6.

### References
- https://github.com/nyuge/rdkit-build
- https://github.com/mcs07/docker-rdkit
- https://launchpad.net/~bkryza/+archive/ubuntu/onedata-deps-gcc7
- https://github.com/lhelontra/tensorflow-on-arm/issues/13
