## [Unreleased]

## [0.1.0] - 2026-10-26

### ✨ Features
- **`guard :status` plugin:** prints one status line after the other guards have run.
- **`rubocop:` and `rspec:` segments:** read the JSON reports of those tools.
- **`file:` segments:** read `<state> <args>` status files, with `states:` for custom states.
- **`title`, `prefix`, `title_color` and `notify` options.**
- **Print only when needed:** prints after a change only when another guard has run for it, learned from Guard's callbacks instead of the changed files.
