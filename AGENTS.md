# Agent instructions

## What not to run

- Never run `setup`, `setup.light` or `task test:smoke`: they install packages and overwrite
  the user's dotfiles; CI runs them on fresh runners. Safe to run: `task test:smoke:light`
  (writes only inside a temporary HOME), `task test:hop` (after changing `src/bin/hop`) and
  `task test:tricks` (after changing tricks).

## Setup

- Entry scripts only install tools; shared steps go in `src/setup/lib.sh`. Find where a tool
  is installed with `tool_prefix`, never with `brew --prefix`.
- Software comes only from Homebrew or mise, which verify what they download; setup never
  fetches files itself or pipes a download into a shell. The one exception: setup.light runs
  the official mise installer from mise.run, which verifies the mise it installs.

## Tool lists

- A new tool goes into `src/Brewfile` and, when it installs without root,
  `src/mise-tools.toml`. Both are plain lists: the same sections in the same order, sorted
  within each section, no explanatory comments. What those comments would say:
  - `mise-tools.toml` must not be named `mise.toml`: mise would load it as the project
    config inside `src/`.
  - `conda:mc` is Midnight Commander; plain `mc` in mise's registry is MinIO's client.
  - trippy is not in mise's registry, hence `github:`.
  - navi has no macOS build and trash-cli is Linux-only, hence their `os` limits.
  - pipes.sh and Cascadia Code have no release file mise can verify by itself, so their
    entries pin the version and the sha256 Homebrew uses; change both together.

## Shell files and configs

- Each shell file's header says which shells read it and what that rules out; follow it.
- Startup files and shipped configs must work when a tool is missing (a host set up without
  it, or a setup that stopped early): run an optional tool at startup only after
  `command -v tool` succeeds, and give configs that call one a fallback (see the git pager).
  Starting a shell must stay silent.

## Every change

- `src/share/cheat.md` is the user's cheat sheet (the `cheat` command). Update it in the same
  change whenever you add, remove, rename or change the behavior of a tool, alias, function,
  script, key binding or user-visible configuration.
- `src/share/tricks.yaml` feeds the `trick` command. When you add or remove a tool, or change
  how one is used, add, update or remove its tricks in the same change; its header lists the
  fields.
- Run `task lint` before handing back changes.
