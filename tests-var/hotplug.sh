#!/bin/bash
#
# Copyright (c) 2015,2016 Krzysztof Kozlowski
# Author: Krzysztof Kozlowski <k.kozlowski.k@gmail.com>
#                             <krzk@kernel.org>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 2 as
# published by the Free Software Foundation.
#

mount -t proc proc /proc
mount -t sysfs sys /sys
mount -t debugfs none /sys/kernel/debug

MAXCPU=3

test -f /sys/kernel/bL_switcher/active && echo 0 > /sys/kernel/bL_switcher/active
for i in `seq 50`; do
for cpu in /sys/devices/system/cpu/cpu[1-${MAXCPU}]/online; do
	echo "Hotplug: $cpu"
	echo 0 > $cpu 2> /dev/null
	sleep .$RANDOM
	echo 1 > $cpu 2> /dev/null
	sleep .$RANDOM
done
done
