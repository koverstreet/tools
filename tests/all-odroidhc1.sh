#!/bin/bash
#
# Copyright (c) 2015-2017 Krzysztof Kozlowski
# Author: Krzysztof Kozlowski <k.kozlowski.k@gmail.com>
#                             <krzk@kernel.org>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 2 as
# published by the Free Software Foundation.
#

set -e -E -x

. $(dirname ${BASH_SOURCE[0]})/inc-common.sh
. $(dirname ${BASH_SOURCE[0]})/odroid-xu3-cpu-online.sh
. $(dirname ${BASH_SOURCE[0]})/odroid-xu3-thermal.sh
. $(dirname ${BASH_SOURCE[0]})/odroid-xu3-board-name.sh
. $(dirname ${BASH_SOURCE[0]})/odroid-xu3-cpu-mmc-stress.sh
. $(dirname ${BASH_SOURCE[0]})/s5p-sss.sh
. $(dirname ${BASH_SOURCE[0]})/s5p-sss-cryptsetup.sh
. $(dirname ${BASH_SOURCE[0]})/usb.sh
. $(dirname ${BASH_SOURCE[0]})/var-all.sh
. $(dirname ${BASH_SOURCE[0]})/clk-s2mps11.sh
# RTC often fail on NFS root so put it at the end
. $(dirname ${BASH_SOURCE[0]})/rtc.sh
# RNG does not work on Odroid, configured in secure mode?
#. $(dirname ${BASH_SOURCE[0]})/rng-exynos.sh

echo "3810000.audss-clock-controller" > /sys/bus/platform/drivers/exynos-audss-clk/unbind
echo "3810000.audss-clock-controller" > /sys/bus/platform/drivers/exynos-audss-clk/bind
echo "Audss rebind: Done"



# Other:
# USB: manual
#reboot
#poweroff