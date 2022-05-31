#!/usr/bin/env bash

CMAKE_BUILD_DIR='cmake-build'

# if build dir can't exist execute `mkdir`
if ! [ -e  $CMAKE_BUILD_DIR ]; then
    mkdir $CMAKE_BUILD_DIR
fi

# shellcheck disable=SC2164
cd $CMAKE_BUILD_DIR

# cmake build
cmake ..

# make build
make

# execute unit test
./sql-parser