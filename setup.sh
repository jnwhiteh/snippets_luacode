#! /usr/bin/env bash

set -e

BASE_DIR=`pwd`

# Download and install Kepler/Lua into a sandbox
mkdir -p sandbox/src

pushd sandbox/src
wget http://spu.tnik.org/files/sputnik-9.03.16-kaio.tar.gz
tar zxf sputnik-9.03.16-kaio.tar.gz
pushd sputnik-9.03.16-kaio

bash install.sh "${BASE_DIR}/sandbox"
popd
popd

# Download and install sputnik mainline as a submodule
git submodule add git://gitorious.org/sputnik/mainline.git sputnik.git

# Link the rocks in sputnik mainline to our current installation
bash sputnik.git/scripts/link_rock.sh -i "${BASE_DIR}/sandbox" -g sputnik.git

