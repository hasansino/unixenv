# Agent instructions

- Never run `setup`, `setup.light` or `task test:smoke`. They install packages and overwrite
  the user's dotfiles; CI runs the smoke tests on fresh runners. `task test:smoke:light` is
  safe to run: it writes only inside a temporary HOME. `task test:hop` is safe too: run it
  after changing `src/bin/hop`.
- `setup` (Homebrew) and `setup.light` (mise, no sudo) share their steps in
  `src/setup/lib.sh`; keep only tool installation in the entry scripts. A new tool goes into
  `src/Brewfile` and, when it installs without root, `src/mise-tools.toml`. Find where a tool
  is installed with `tool_prefix`, never with `brew --prefix`.
- `src/Brewfile` and `src/mise-tools.toml` are plain dependency lists: the same sections in
  the same order, sorted within each section, no explanatory comments. Facts to keep in
  mind instead: `mise-tools.toml` must not be named `mise.toml` (mise would load it as the
  project config inside `src/`); `conda:mc` is Midnight Commander, while plain `mc` in
  mise's registry is MinIO's client; navi has no macOS build and trash-cli is Linux-only,
  hence their `os` limits.
- Anything setup downloads outside a package manager is pinned in `src/pinned/pinned.toml` (release, platform,
  checksum) and read through `pin`; `task check:pins` reports newer releases. Never fetch an
  unpinned file or pipe a download into a shell in setup. One exception so far: setup.light runs
  the official mise installer from mise.run, which verifies the mise it installs.
- `src/generic/rc` and `src/generic/aliases` are read by both zsh and bash: no array
  indexing, quote every variable, and define functions as `function name {` (an
  existing alias with the same name breaks `name() {`).
- Shell startup files and shipped configs must work when a tool is missing (a host set up
  without it, or a setup that stopped early): run an optional tool at startup only after
  `command -v tool` succeeds, and give configs that call one a fallback (see the git pager).
  Starting a shell must stay silent.
- `cheat.md` is the user's cheat sheet (the `cheat` command). Update it in the
  same change whenever you add, remove, rename or change the behavior of a tool, alias,
  function, script, key binding or user-visible configuration.
- Run `task lint` before handing back changes.
