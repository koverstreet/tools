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

test_clk_s2mps11() {
	local name="clk-s2mps11"
	local clk_name=""
	local clk_suffixes=""
	print_msg "Testing..."

	case "$(get_board_compatible)" in
	hardkernel,odroid-hc1|hardkernel,odroid-xu3|hardkernel,odroid-xu3-lite|hardkernel,odroid-xu4)
		clk_name="s2mps11"
		clk_suffixes="ap bt cp"
		;;
	hardkernel,odroid-u3)
		clk_name="32khz"
		clk_suffixes="ap cp pmic"
		;;
	*)
		error_msg "Wrong board"
	esac

	for clk in $clk_suffixes; do
		clk_path="/sys/kernel/debug/clk/${clk_name}_${clk}"
		test -d "$clk_path" || print_msg "ERROR: No ${clk_name}_${clk}"

		test_cat "${clk_path}/clk_enable_count" 0
		test_cat "${clk_path}/clk_notifier_count" 0
		if [ "$clk" == "ap" ]; then
			test_cat "${clk_path}/clk_prepare_count" 1
		else
			test_cat "${clk_path}/clk_prepare_count" 0
		fi
		test_cat "${clk_path}/clk_rate" 32768
	done

	print_msg "OK"
}

test_clk_s2mps11
