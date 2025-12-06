#!/usr/bin/env bash
set -euo pipefail

# Build the deployable dist/ tree for Cloudflare Pages in one step.
# Usage: ./src/build-dist.sh [<.deb file or directory> ...]
# Env:
#   DOCS_BUILD_CMD (optional) command to build docs into dist/docs/ (e.g., "npm ci && npm run build").
#   REPO_SIGNING_KEY (optional) GPG key ID or fingerprint used by reprepro to sign Release files.
# Inputs:
#   - One or more .deb paths passed as arguments, OR (if no args) all .debs under artifacts/*/.
#   - APT config in src/apt/conf/.
# Outputs:
#   - dist/dists/ and dist/pool/ (via reprepro), dist/docs/ (if built), dist/robots.txt, dist/sitemap.xml, dist/index.html.
# Side effects:
#   - Cleans/recreates APT subtrees in dist/, optional signing if REPO_SIGNING_KEY is set, fails fast on missing inputs.

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DIST_DIR="${ROOT_DIR}/dist"
APT_SCRIPT="${ROOT_DIR}/src/apt/scripts/build-apt-repo.sh"
ROOT_SITE_DIR="${ROOT_DIR}/src/root-site"

log() { printf '==> %s\n' "$*"; }
usage() {
  cat <<'EOF'
Usage: build-dist.sh <.deb file or directory> [additional .deb paths]
Builds the complete dist/ tree for deployment (APT + docs + crawl directives).
EOF
}

command -v reprepro >/dev/null 2>&1 || { echo "reprepro is required on PATH" >&2; exit 1; }

[[ -f "${ROOT_SITE_DIR}/robots.txt" ]] || { echo "robots.txt missing in ${ROOT_SITE_DIR}" >&2; exit 1; }
[[ -f "${ROOT_SITE_DIR}/sitemap.xml" ]] || { echo "sitemap.xml missing in ${ROOT_SITE_DIR}" >&2; exit 1; }
[[ -d "${ROOT_DIR}/src/apt/conf" ]] || { echo "APT config dir missing: ${ROOT_DIR}/src/apt/conf" >&2; exit 1; }

deb_inputs=()
if [[ $# -gt 0 ]]; then
  deb_inputs=("$@")
else
  while IFS= read -r -d '' file; do deb_inputs+=("$file"); done < <(find "${ROOT_DIR}/artifacts" -maxdepth 2 -type f -name '*.deb' -print0 | sort -z)
fi

[[ ${#deb_inputs[@]} -gt 0 ]] || { echo "No .deb inputs found (pass paths or populate artifacts/*/*.deb)" >&2; exit 1; }

log "Building APT repository"
"${APT_SCRIPT}" "${deb_inputs[@]}"

log "Validating APT repository structure"
[[ -d "${DIST_DIR}/dists" ]] || { echo "dist/dists missing" >&2; exit 1; }
[[ -d "${DIST_DIR}/pool" ]] || { echo "dist/pool missing" >&2; exit 1; }
[[ -f "${DIST_DIR}/dists/stable/Release" ]] || { echo "dist/dists/stable/Release missing" >&2; exit 1; }
find "${DIST_DIR}/pool" -type f -name '*.deb' | grep -q . || { echo "No .deb files found under dist/pool" >&2; exit 1; }

log "Smoke testing APT repository output"
reprepro -b "${DIST_DIR}" list stable
reprepro -b "${DIST_DIR}" checkpool

if [[ -n "${DOCS_BUILD_CMD:-}" ]]; then
  log "Building docs site via DOCS_BUILD_CMD"
  pushd "${ROOT_DIR}/src/docs-site" >/dev/null
  # Allow caller to provide full build command (e.g., npm ci && npm run build -- --outDir ../../dist/docs)
  bash -c "${DOCS_BUILD_CMD}"
  popd >/dev/null
else
  log "Skipping docs build (DOCS_BUILD_CMD not set)"
fi

log "Copying crawl directives into dist/"
mkdir -p "${DIST_DIR}"
cp "${ROOT_SITE_DIR}/robots.txt" "${DIST_DIR}/robots.txt"
cp "${ROOT_SITE_DIR}/sitemap.xml" "${DIST_DIR}/sitemap.xml"
if [[ -f "${ROOT_SITE_DIR}/index.html" ]]; then
  cp "${ROOT_SITE_DIR}/index.html" "${DIST_DIR}/index.html"
fi

log "dist/ is ready for Cloudflare Pages deployment"
