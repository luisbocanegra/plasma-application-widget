#!/bin/sh

if [ -d "build" ]; then
    rm -rf build
fi

# Install widget for current user
cmake -B build/plasmoid -S . -DINSTALL_PLASMOID=ON
cmake --build build/plasmoid
cmake --install build/plasmoid
