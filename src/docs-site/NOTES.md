## Planned Site Structure

This notes file outlines the intended structure for the documentation site before the static site generator is wired up. The site will guide visitors from a welcoming home page to package listings and detailed per-tool pages without requiring API calls or client-side routing. Each page will be generated statically so the deployed `dist/docs/` tree is fully crawlable and easily hosted. The first package focus will be `compose-upgrade`, but the layout should expand cleanly as more tools are added. Navigation and metadata should be kept simple so future builders can translate this outline into templates and content files.

- **Home page overview** Introduces the repository, highlights supported distributions, and links to the quick-start instructions for adding the APT source.
- **Package listing page** Summarizes all published tools with short descriptions, supported architectures, and links to their dedicated pages and upstream sources.
- **Per-tool detail pages** Provide installation commands, usage examples, changelog pointers, and outbound links for each tool such as `compose-upgrade`.
- **Repo operations page** Describes how the APT repository is built, signed, and versioned so users and contributors understand trust and update cadence.
- **Support and feedback page** Points visitors to issue trackers, contact methods, and contribution guidelines for the repository and published tools.
