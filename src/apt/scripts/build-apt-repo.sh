#!/usr/bin/env bash
set -euo pipefail

# Build the Debian/Ubuntu APT repository into dist/ using provided .deb artifacts.
# Usage: ./src/apt/scripts/build-apt-repo.sh /path/to/deb/dir [more/paths/or/files.deb]
# Env: REPO_SIGNING_KEY (optional) to sign Release files with reprepro.

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
DIST_DIR="${ROOT_DIR}/dist"
CONF_SRC="${ROOT_DIR}/src/apt/conf"
CONF_DST="${DIST_DIR}/conf"

log() { printf '==> %s\n' "$*"; }
usage() {
	cat <<'EOF'
Usage: build-apt-repo.sh <.deb file or directory> [additional .deb paths]
Builds dist/dists/ and dist/pool/ using reprepro with config from src/apt/conf/.
Provide one or more .deb files or directories containing .deb artifacts.
EOF
}

[[ $# -ge 1 ]] || { usage >&2; exit 1; }
command -v reprepro >/dev/null 2>&1 || { echo "reprepro is required on PATH" >&2; exit 1; }

deb_inputs=()
for path in "$@"; do
	if [[ -d "$path" ]]; then
		while IFS= read -r -d '' file; do deb_inputs+=("$file"); done < <(find "$path" -type f -name '*.deb' -print0)
	elif [[ -f "$path" && "$path" == *.deb ]]; then
		deb_inputs+=("$path")
	else
		echo "Skipping non-.deb input: $path" >&2
	fi
done

[[ ${#deb_inputs[@]} -gt 0 ]] || { echo "No .deb inputs found" >&2; exit 1; }

SIGN_ARGS=()
if [[ -n "${REPO_SIGNING_KEY:-}" ]]; then
	SIGN_ARGS+=(--sign-with "${REPO_SIGNING_KEY}")
fi

log "Preparing dist layout"
mkdir -p "$DIST_DIR"
rm -rf "${DIST_DIR}/dists" "${DIST_DIR}/pool" "$CONF_DST"
mkdir -p "${DIST_DIR}/dists" "${DIST_DIR}/pool"
cp -a "${CONF_SRC}" "$CONF_DST"

log "Including ${#deb_inputs[@]} package(s) into stable/main"
for deb in "${deb_inputs[@]}"; do
	reprepro -b "$DIST_DIR" "${SIGN_ARGS[@]}" includedeb stable "$deb"
done

log "Exporting metadata"
reprepro -b "$DIST_DIR" "${SIGN_ARGS[@]}" export

log "Done. dist/ now contains dists/ and pool/ ready for deployment."
