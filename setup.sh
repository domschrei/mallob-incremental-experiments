#!/bin/bash

set -e

if [ ! -d mallob ]; then
	git clone git@github.com:domschrei/mallob.git
fi

if [ ! -d bridge ]; then
	git clone git@github.com:domschrei/mallob-ipasir-bridge.git
	mv mallob-ipasir-bridge bridge
fi

mkdir -p applications
if [ ! -d applications/lilotane ]; then
	git clone git@github.com:domschrei/lilotane.git
	mv lilotane applications/lilotane
	( cd lilotane && git checkout mallotane )
fi


# Build Mallob
cd mallob
( cd lib && bash fetch_and_build_sat_solvers.sh kcgyl )
mkdir -p build
cd build
cmake .. -DCMAKE_BUILD_TYPE=RELEASE -DMALLOB_ASSERT=1 -DMALLOB_ASSERT_HEAVY=0 -DMALLOB_USE_GLUCOSE=1 -DMALLOB_USE_ASAN=0 -DMALLOB_USE_JEMALLOC=1 -DMALLOB_LOG_VERBOSITY=6 -DMALLOB_SUBPROC_DISPATCH_PATH=\"build/\" -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
make VERBOSE=1 -j$(nproc)
cd ..
cd ..

# Build Bridge
cd bridge
make MALLOB_BASE_DIRECTORY='\"'$(pwd)/../mallob'\"' MALLOB_API_INDEX='\"'0'\"' VERBOSE=1 -j$(nproc)
cd ..

# Copy Bridge library to applications
cp bridge/libipasirmallob.a applications/lilotane/lib/mallob/

# Build Lilotane
cd applications/lilotane
mkdir -p build
cd build
cmake .. -DCMAKE_BUILD_TYPE=RELEASE -DIPASIRSOLVER=mallob
make VERBOSE=1 -j$(nproc)
cd ..
cp build/lilotane run

