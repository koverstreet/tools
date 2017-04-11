/*
 * Copyright (C) 2017, Stephan Mueller <smueller@chronox.de>
 *
 * License: see COPYING file in root directory
 *
 * THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED
 * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE, ALL OF
 * WHICH ARE HEREBY DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT
 * OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
 * BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE
 * USE OF THIS SOFTWARE, EVEN IF NOT ADVISED OF THE POSSIBILITY OF SUCH
 * DAMAGE.
 */

#include <unistd.h>
#include <errno.h>
#include <limits.h>
#include <stdint.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <linux/random.h>
#ifdef HAVE_GETRANDOM
#include <sys/random.h>
#endif

#include <kcapi.h>

struct kcapi_handle *rng = NULL;

static int read_complete(int fd, uint8_t *buf, uint32_t buflen)
{
	ssize_t ret;

	do {
		ret = read(fd, buf, buflen);
		if (0 < ret) {
			buflen -= ret;
			buf += ret;
		}
	} while ((0 < ret || EINTR == errno || ERESTART == errno)
		 && buflen > 0);

	if (buflen == 0)
		return 0;
	return 1;
}

static int read_random(uint8_t *buf, uint32_t buflen)
{
	int fd;
	int ret = 0;

	fd = open("/dev/urandom", O_RDONLY|O_CLOEXEC);
	if (0 > fd)
		return fd;

	ret = read_complete(fd, buf, buflen);
	close(fd);
	return ret;
}

static int get_random(uint8_t *buf, uint32_t buflen)
{
	if (buflen > INT_MAX)
		return 1;

#ifdef HAVE_GETRANDOM
	return getrandom(buf, buflen, 0);
#else
# ifdef __NR_getrandom
	do {
		int ret = syscall(__NR_getrandom, buf, buflen, 0);

		if (0 < ret) {
			buflen -= ret;
			buf += ret;
		}
	} while ((0 < ret || EINTR == errno || ERESTART == errno)
		 && buflen > 0);

	if (buflen == 0)
		return 0;

	return 1;
# else
	return read_random(buf, buflen);
# endif
#endif
}

static void usage(void)
{
	char version[30];
	uint32_t ver = kcapi_version();

	memset(version, 0, sizeof(version));
	kcapi_versionstring(version, sizeof(version));

	fprintf(stderr, "\nKernel Crypto API Random Number Gatherer\n");
	fprintf(stderr, "\nKernel Crypto API interface library version: %s\n", version);
	fprintf(stderr, "Reported numeric version number %u\n\n", ver);
	fprintf(stderr, "Usage:\n");
	fprintf(stderr, "\t<NUM>\tNumber of bytes to generate\n");
}

int main(int argc, char *argv[])
{
	int ret;
	uint8_t buf[64];
	unsigned long outlen;

	if (argc != 2) {
		usage();
		return -EINVAL;
	}

	outlen = strtoul(argv[1], NULL, 10);
	if (outlen == ULONG_MAX) {
		usage();
		return -EINVAL;
	}

	ret = kcapi_rng_init(&rng, "stdrng", 0);
	if (ret)
		return ret;

	ret = get_random(buf, sizeof(buf));
	if (ret)
		goto out;

	ret = kcapi_rng_seed(rng, buf, sizeof(buf));
	kcapi_memset_secure(buf, 0, sizeof(buf));
	if (ret)
		goto out;

	while (outlen) {
		uint32_t todo = (outlen < sizeof(buf)) ? outlen : sizeof(buf);

		ret = kcapi_rng_generate(rng, buf, todo);
		if (ret < 0)
			goto out;

		if ((uint32_t)ret != todo) {
			ret = -EFAULT;
			goto out;
		}

		fwrite(&buf, todo, 1, stdout);

		outlen -= todo;
	}

out:
	if (rng)
		kcapi_rng_destroy(rng);
	kcapi_memset_secure(buf, 0, sizeof(buf));

	return ret;
}
