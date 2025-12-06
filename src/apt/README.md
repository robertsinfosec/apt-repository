## APT Build Source

This directory contains the source configuration and scripts used to build the APT repository into the `dist/` directory. Configuration files for tools such as reprepro should live under `src/apt/conf/`, and build or helper scripts should live under `src/apt/scripts/`. The goal is that running these scripts will construct `dist/dists/` and `dist/pool/` based on provided `.deb` files without requiring manual changes to `dist/`.

