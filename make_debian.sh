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

# 2. Setup Staging Environment
mkdir -p "pkg/lib/modules/$(uname -r)/extra"
mkdir -p "pkg/etc/udev/rules.d"
mkdir -p "pkg/etc/modprobe.d"
mkdir -p "pkg/DEBIAN"

# 3. COPY existing config files instead of echoing
cp "$srcdir/galcore.ko" "pkg/lib/modules/$(uname -r)/extra/"
cp "debian-config/99-galcore.rules" "pkg/etc/udev/rules.d/"
cp "debian-config/postinst" "pkg/DEBIAN/"

# Ensure the postinst is executable (Mandatory for dpkg)
chmod 755 "pkg/DEBIAN/postinst"

# 4. Generate the Control file
cp "debian-config/control" "pkg/DEBIAN/control"

# 5. Build the final .deb
dpkg-deb --build "pkg" "galcore-unified-driver-a733.deb"