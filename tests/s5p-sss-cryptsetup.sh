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

set -e -E
. $(dirname ${BASH_SOURCE[0]})/inc-common.sh

prepare_s5p_sss_cryptsetup() {
	local name="s5p-sss cryptsetup"
	local dev="$1"

	local status="$(cryptsetup status $dev | head -n 1)"
	if [ "$status" != "/dev/mapper/testcrypt is inactive." ]; then
		print_msg "Crypt device $dev is being used"
		return 1
	fi

	if [ -f /tmp/${dev} ]; then
		print_msg "/tmp/${dev} already exists"
		return 1
	fi

	dd if=/dev/zero of=/tmp/${dev} bs=32M count=0 seek=1 status=none

	#cryptsetup -v -q --cipher aes-cbc-essiv --hash sha256 --use-urandom --key-file=/dev/urandom --master-key-file=/dev/urandom --keyfile-size=256 --key-size=256 luksFormat /tmp/${dev}
	cryptsetup -v -q --cipher=aes-cbc-essiv:sha256 --hash=sha256 \
		--key-file=/dev/urandom --master-key-file=/dev/urandom \
		--keyfile-size=256 --key-size=256 --type plain \
		open /tmp/${dev} $dev
	cryptsetup status $dev

	return 0
}

unprepare_s5p_sss_cryptsetup() {
	local name="s5p-sss cryptsetup"
	local dev="$1"

	cryptsetup close $dev

	rm -f /tmp/${dev}
}

test_s5p_sss_cryptsetup() {
	local name="s5p-sss cryptsetup"
	local dev="testcrypt"
	print_msg "Testing..."

	prepare_s5p_sss_cryptsetup $dev

	for i in `seq 0 1000`; do
		echo "1234567890123456789012345678901234567890" | dd of=/dev/mapper/${dev} \
			bs=1 seek=$(expr $i \* 40) status=none
	done
	sync && sync && sync

	dd if=/dev/mapper/${dev} of=/dev/null bs=32M count=1
	sync && sync && sync

	dd if=/dev/zero of=/dev/mapper/${dev} bs=32M count=1
	sync && sync && sync

	dd if=/dev/mapper/${dev} of=/dev/null bs=32M count=1
	sync && sync && sync

	unprepare_s5p_sss_cryptsetup $dev

	print_msg "Done"
}

test_s5p_sss_cryptsetup
