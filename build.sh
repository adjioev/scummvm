#!/usr/bin/env bash
#
# Convenience build script for this ScummVM fork.
# See engines/kyra/README-EOB-enhancements.md for the Eye of the Beholder features.
#
# Usage:
#   ./build.sh            Configure (if needed) and build everything.
#   ./build.sh kyra       Fast build: only the KYRA engine (Eye of the Beholder,
#                         Kyrandia, Lands of Lore). Reconfigures to engine-only.
#   ./build.sh run [args] Launch the built binary (passes args through to scummvm).
#   ./build.sh clean      Remove build objects (keeps configuration).
#   ./build.sh distclean  Remove build objects and configuration.
#
set -euo pipefail
cd "$(dirname "$0")"

# Parallel jobs: number of CPUs, falling back to 4.
JOBS="$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 4)"

CMD="${1:-build}"

case "$CMD" in
	build)
		# Reuse an existing configuration; only run ./configure on a fresh tree.
		if [ ! -f config.mk ]; then
			echo ">> No config found, running ./configure ..."
			./configure
		fi
		echo ">> Building with -j${JOBS} ..."
		make -j"${JOBS}"
		echo ">> Done. Binary: $(pwd)/scummvm"
		;;

	kyra|eob)
		# Configure for the KYRA engine only - much faster to build than the full
		# set of engines, and all that is needed for Eye of the Beholder.
		echo ">> Configuring KYRA engine only ..."
		./configure --disable-all-engines --enable-engine=kyra
		echo ">> Building with -j${JOBS} ..."
		make -j"${JOBS}"
		echo ">> Done. Binary: $(pwd)/scummvm (KYRA only)"
		;;

	run)
		shift || true
		if [ ! -x ./scummvm ]; then
			echo "!! scummvm is not built yet - run ./build.sh first." >&2
			exit 1
		fi
		exec ./scummvm "$@"
		;;

	clean)
		make clean
		;;

	distclean)
		make distclean 2>/dev/null || true
		;;

	-h|--help|help)
		sed -n '3,13p' "$0"
		;;

	*)
		echo "Unknown command: ${CMD}" >&2
		echo "Try: ./build.sh --help" >&2
		exit 1
		;;
esac
