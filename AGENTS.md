# Agent instructions

- Never run `setup` or `task test:smoke`. Both install brew packages globally and
  overwrite the user's dotfiles; CI runs the smoke test on fresh runners.
- `src/generic/rc` and `src/generic/aliases` are read by both zsh and bash: no array
  indexing, and quote every variable.
- Run `task lint` before handing back changes.
