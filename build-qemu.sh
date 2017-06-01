#!/bin/bash
#
# Copyright (c) 2017 Krzysztof Kozlowski
# Author: Krzysztof Kozlowski <k.kozlowski.k@gmail.com>
#                             <krzk@kernel.org>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 2 as
# published by the Free Software Foundation.
#

set +e +E

TEST=0
CC="cc"
CC="ccache $CC"
CXX="c++"
CXX="ccache $CXX"

if [ "$1" == "test" ]; then
    TEST=1
fi

../qemu/configure --cc="$CC" --cxx="$CXX" --enable-debug --enable-fdt --enable-kvm --enable-libusb --enable-libssh2 --enable-lzo --enable-bzip2 --enable-curses --enable-gtk  --enable-cap-ng --enable-debug-tcg

make -j8

if [ $TEST -eq 1 ]; then
    sudo modprobe kvm_intel
    sudo service docker start

    echo "make check"
    make check

    echo "Testing: docker-test-quick@centos6"
    make docker-test-quick@centos6

    echo "Testing: docker-test-mingw@fedora"
    make docker-test-mingw@fedora

    echo "Testing: docker-test-build@min-glib"
    make docker-test-build@min-glib
fi
