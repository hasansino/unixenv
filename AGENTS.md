# Agent instructions

- Never run `setup` or `task test:smoke`. Both install brew packages globally and
  overwrite the user's dotfiles; CI runs the smoke test on fresh runners.
- `src/generic/rc` and `src/generic/aliases` are read by both zsh and bash: no array
  indexing, quote every variable, and define functions as `function name {` (an
  existing alias with the same name breaks `name() {`).
- `cheat.md` is the user's cheat sheet (the `cheat` command). Update it in the
  same change whenever you add, remove, rename or change the behavior of a tool, alias,
  function, script, key binding or user-visible configuration.
- Run `task lint` before handing back changes.
