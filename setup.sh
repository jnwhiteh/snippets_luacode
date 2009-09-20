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
git submodule init
git submodule update

pushd sputnik.git
git checkout master
popd

# Link the rocks in sputnik mainline to our current installation
bash sputnik.git/scripts/link_rock.sh -i "${BASE_DIR}/sandbox" -g sputnik.git

# Link the recipe rock into the Luarocks installation

mkdir sandbox/rocks/recipes
ln -s "${BASE_DIR}/recipes" sandbox/rocks/recipes/cvs-1
sandbox/bin/luarocks-admin make-manifest

# Patch sputnik.ws

patch sandbox/sputnik.ws << ENDPATCH
4c4,4
<    BASE_URL       = '/sputnik.ws',
---
>    BASE_URL       = '/',
ENDPATCH
