#!/usr/bin/env bash
set -euo pipefail

# Build a Debian package for compose-upgrade using the debian/ packaging layout.
# Usage: build-deb.sh [output-root] [version]
# Defaults: output-root=artifacts, version=0.1.0-1
# Inputs: tool source under src/tools/compose-upgrade (bin/, man/)
# Outputs: artifacts/compose-upgrade/compose-upgrade_<version>_all.deb
# Requirements: debhelper, dpkg-dev, fakeroot (recommended), gzip, debuild/dpkg-buildpackage.

TOOL_NAME="compose-upgrade"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_ROOT="${1:-artifacts}"
OUT_DIR="${OUT_ROOT}/${TOOL_NAME}"
VERSION="${2:-0.1.0-1}"

log() { printf '==> %s\n' "$*"; }
cleanup() { [[ -d "${STAGE_DIR:-}" ]] && rm -rf "$STAGE_DIR"; }
trap cleanup EXIT

command -v dpkg-buildpackage >/dev/null || { echo "dpkg-buildpackage is required" >&2; exit 1; }

STAGE_DIR="$(mktemp -d)"
install -d "$OUT_DIR"

# Stage source and packaging into a clean build tree so the repo workspace stays untouched.
cp -a "${ROOT_DIR}/bin" "${ROOT_DIR}/man" "$STAGE_DIR/"
cp -a "${ROOT_DIR}/packaging/debian" "$STAGE_DIR/debian"

# Refresh changelog with the requested version and current date to align build outputs.
DATE_RFC="$(date -R)"
cat >"${STAGE_DIR}/debian/changelog" <<EOF
${TOOL_NAME} (${VERSION}) unstable; urgency=medium

  * Automated build from repo tooling.

 -- Roberts InfoSec <packages@robertsinfosec.com>  ${DATE_RFC}
EOF

log "Building ${TOOL_NAME} ${VERSION}"
pushd "$STAGE_DIR" >/dev/null
dpkg-buildpackage -b -us -uc
popd >/dev/null

# Collect the generated .deb from the staging parent directory.
PARENT_DIR="$(dirname "$STAGE_DIR")"
DEB_PATH_SRC="$(find "$PARENT_DIR" -maxdepth 1 -type f -name "${TOOL_NAME}_${VERSION}_all.deb" -o -name "${TOOL_NAME}_*.deb" | head -n1)"
[[ -n "$DEB_PATH_SRC" ]] || { echo "No built .deb found" >&2; exit 1; }

DEB_PATH_DEST="${OUT_DIR}/$(basename "$DEB_PATH_SRC")"
mv "$DEB_PATH_SRC" "$DEB_PATH_DEST"

log "Built ${DEB_PATH_DEST}"
