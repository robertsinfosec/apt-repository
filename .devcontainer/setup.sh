#!/usr/bin/env bash
set -euo pipefail

echo "[setup] Running devcontainer setup for apt-repository"

# Ensure core source and docs directories exist
mkdir -p docs
mkdir -p src/apt/conf
mkdir -p src/apt/scripts
mkdir -p src/docs-site
mkdir -p dist

# Place simple placeholder README files if they do not exist
if [ ! -f src/apt/README.md ]; then
  cat <<'EOF' > src/apt/README.md
## APT Build Source

This directory contains the source configuration and scripts used to build the APT repository into the `dist/` directory. Configuration files for tools such as reprepro should live under `src/apt/conf/`, and build or helper scripts should live under `src/apt/scripts/`. The goal is that running these scripts will construct `dist/dists/` and `dist/pool/` based on provided `.deb` files without requiring manual changes to `dist/`.

EOF
fi

if [ ! -f src/docs-site/README.md ]; then
  cat <<'EOF' > src/docs-site/README.md
## Docs Site Source

This directory contains the source code for the static documentation site that will be served from `/docs` on `https://apt.robertsinfosec.com`. A static site generator such as a Vite-based SSG should be configured here so that the build process outputs HTML, CSS, and related assets into `dist/docs/`. The resulting site should explain what the APT repository is, how to add it, and how to install and use packages such as `compose-upgrade`.

EOF
fi
