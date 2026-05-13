#!/usr/bin/env bash

set -euo pipefail

# Make sure the repository is clean before we start. We don't want to mess with any uncommitted changes.
git restore ./
git clean -fdx ./

# Apply the kernel 6.6 patch
patch -p1 < galcore_6.6_kernel_api_drift.patch

# We are ready to start building the Debian package
kdir="/lib/modules/$(uname -r)/build"
srcdir="$(pwd)/aw_nna_galcore"

make -C "$kdir" M="$srcdir" modules

mkdir -p pkg/