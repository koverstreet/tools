#!/bin/bash
#
# Copyright (c) 2015 Krzysztof Kozlowski
# Author: Krzysztof Kozlowski <k.kozlowski.k@gmail.com>
#                             <krzk@kernel.org>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 2 as
# published by the Free Software Foundation.
#

. $(dirname ${BASH_SOURCE[0]})/inc-build-slave.sh

set -e -E

test $# -eq 2 || die "Wrong number of parameters"

NAME="$1"
OUT_DIR="$2"

if [ ! -f "arch/arm/boot/dts/exynos5422-odroidxu3-lite.dts" ]; then
	# If there is no Odroid XU3 Lite DTS, then duplicate the XU3 DTB
	echo "No Odroid XU3 Lite DTS, using regular XU3"
	cp ${OUT_DIR}/arch/arm/boot/dts/exynos5422-odroidxu3.dtb ${OUT_DIR}/arch/arm/boot/dts/exynos5422-odroidxu3-lite.dtb
fi

# Remove old modules-out
rm -fr "${OUT_DIR}/modules-out"
# Install modules into modules-out
build-slave.sh INSTALL_MOD_STRIP=1 INSTALL_MOD_PATH=modules-out modules_install
# Delete symlinks from modules-out
find "${OUT_DIR}/modules-out/lib/modules/" -type l -delete
# Tar the modules-out (download cannot transfer entire directories)
tar -czf "${OUT_DIR}/modules-out.tar.gz" -C "${OUT_DIR}/modules-out" lib/modules
