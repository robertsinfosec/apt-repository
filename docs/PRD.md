## Project Overview

This repository, `apt-repository`, is the source code and configuration for the APT repository served at `https://apt.robertsinfosec.com`. It is a normal GitHub source repository that follows GitHub conventions, with human documentation under `docs/`, implementation code and build tooling under `src/`, and build artifacts under `dist/`. The actual APT repository layout consumed by `apt` is generated into `dist/` as part of a build process and is then deployed to the hosting environment, such as Cloudflare Pages. The first tool supported by this repository will be `compose-upgrade`, with the design explicitly allowing additional tools to be published later.

## Goals and Non-Goals

The primary goal is to provide a professional APT repository experience so that users can add a single repository URL and install tools with standard `apt install` commands. A secondary goal is to provide clear, discoverable documentation so that anyone who visits `https://apt.robertsinfosec.com` in a browser understands what the repository is, how to add it, what packages it offers, and where the source and deeper docs live. Another important goal is to separate source from build artifacts, making the structure maintainable and clear for future contributors and automation.

This repository is not the home for the tools’ source code themselves. Each tool, such as `compose-upgrade`, will be maintained in its own repository or in a shared tools monorepo and will produce `.deb` artifacts that this repository consumes. It is also not the goal, at least initially, to integrate with the official Debian or Ubuntu archives. Instead, this project behaves like a third party vendor repository that users explicitly add to their systems.

## High-Level Architecture

The high-level architecture is split between source directories and build output. All implementation and configuration used to construct the APT repository lives in `src/`, while the final deployable repository tree lives in `dist/`. Under `src/apt/`, there will be configuration templates for the APT repository (for example, `src/apt/conf/` for reprepro configuration) and scripts that know how to transform `.deb` artifacts into a proper Debian-style repository under `dist/`. Under `src/docs-site/`, there will be the source for a statically generated documentation site that is built into `dist/docs/` and served from `/docs` on the final site.

The `dist/` directory is the build artifact tree that matches the structure expected by `apt` and by browsers. It will contain `dists/` and `pool/` directories for APT, as well as a `docs/` directory for the documentation site, along with supporting files like `robots.txt` and `sitemap.xml`. A deployment process outside this document will upload the `dist/` tree to the hosting provider so that `https://apt.robertsinfosec.com` serves content directly from `dist/`. The separation between `src/` and `dist/` makes it clear what is hand-authored source and what is generated output.

## Directory Layout Requirements

The repository must follow a consistent layout that distinguishes human documentation, implementation code, and build artifacts. Human oriented project documentation, such as design notes and architecture overviews, must live under `docs/` and should not be mixed with the generated documentation site. Implementation code, build scripts, and configuration used to construct the APT repository and the docs site must live under `src/`. In particular, APT specific configuration such as reprepro configuration files should live under `src/apt/conf/`, and any supporting scripts such as `build-apt-repo` or related helpers should live under `src/apt/scripts/`.

The `dist/` directory is reserved for build output and must not be hand-edited. When the build runs, it will create or refresh `dist/` with an APT layout that includes `dist/dists/` and `dist/pool/`, a documentation site under `dist/docs/`, and any root-level files needed by the deployed site such as `dist/index.html`, `dist/robots.txt`, and `dist/sitemap.xml`. The intent is that `dist/` can be safely deleted and recreated by the build whenever needed, while `src/` remains the single source of truth for how the APT repository is constructed.

## Documentation Site Requirements

The documentation site will be served from `https://apt.robertsinfosec.com/docs` and must be generated as static HTML so that it is easily indexable by search engines and readable by simple HTTP clients. Its source should live under `src/docs-site/`, using a static site generation approach such as a Vite-based SSG or similar. The build process for the docs should output HTML, CSS, and related assets into `dist/docs/`, with a corresponding redirect or simple index at `dist/index.html` so that visiting `/` sends browser users to `/docs`.

The documentation should explain what the APT repository is, how to add it to a system, and list available tools with short descriptions and links to their main documentation and source repos. There should also be a `robots.txt` and `sitemap.xml` at the root of the deployed site, generated or maintained as part of the build, so that search engines know to crawl `/docs` and can ignore APT specific paths like `/dists` and `/pool`. These two files should be produced into `dist/` and never hand-edited outside the `src/` driven build.

## Initial Package: compose-upgrade

The first package to be published through this APT repository will be `compose-upgrade`, a Bash-based helper for performing robust Docker Compose upgrades. Its source code and Debian packaging configuration will live in a separate repository or monorepo, which will produce `.deb` artifacts. This repository will treat those `.deb` files as inputs to the build process, placing them in the appropriate location under `dist/pool/` and updating the relevant metadata under `dist/dists/` so that `apt` can discover and install them.

The documentation site under `/docs` should include at least one page dedicated to `compose-upgrade`. That page should describe what the tool does, how to install it using this APT repository, and how to use it in common scenarios. It should also link to the canonical GitHub source and, where appropriate, to its man page or other detailed technical documentation.

## CI and Automation Expectations

This repository is expected to integrate with CI, such as GitHub Actions, to automate building the `dist/` tree. The CI pipeline should be capable of pulling or receiving `.deb` artifacts for one or more tools, running the APT repository build scripts from `src/apt/scripts/`, and generating a complete and signed APT repository structure under `dist/`. It should also build the static documentation site from `src/docs-site/` into `dist/docs/`, and generate or update `dist/robots.txt` and `dist/sitemap.xml`. The final CI step will publish the `dist/` directory to the hosting environment.

The CI configuration should be modular enough to evolve as additional packages, distributions, or architectures are added. Comments in the workflow files should clearly explain how `.deb` inputs are discovered, how APT metadata is updated, and how the docs site is built and deployed. The local developer experience inside the dev container should mirror the CI behavior as closely as reasonable so that developers can test builds of `dist/` before pushing changes.
