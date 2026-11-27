# unixenv cheat

## Files and search

| Command                | What it does                                           |
|------------------------|--------------------------------------------------------|
| `bat file`             | cat with colors; `-A` shows tabs and line ends         |
| `ll`                   | ls -la, folders first                                  |
| `fd -e go test`        | find files by name; dotfiles yes, .gitignore no        |
| `rg -t go 'func main'` | fast grep -r; `-l` lists files only                    |
| `z uni` · `z` · `zi`   | jump to a known folder · pick with fzf · zoxide picker |
| `dust -d 2` · `ds`     | disk usage tree · du summary                           |
| `btm` · `htop`         | system monitor                                         |
| `tldr tar`             | short examples instead of man                          |
| `trash file`           | rm into the Trash                                      |
| `glow -p file.md`      | render markdown                                        |
| `cnt` · `path`         | count files here · PATH one per line                   |

## Keys

| Key                       | What it does                                      |
|---------------------------|---------------------------------------------------|
| `Ctrl-R`                  | search history; again sorts by time               |
| `Ctrl-T`                  | paste a file path                                 |
| `Alt-C`                   | jump into a subfolder (iTerm2: Option sends Esc+) |
| `Ctrl-G`                  | navi cheat sheets                                 |
| `→`                       | accept the history suggestion (zsh)               |
| `'exact ^start end$ !not` | fzf search syntax; space means AND                |

## Git

| Command                           | What it does                                                                                              |
|-----------------------------------|-----------------------------------------------------------------------------------------------------------|
| `gs` · `gb` · `gl` · `gco` · `ga` | status · branches · graph log · checkout · add .                                                          |
| `grb 3`                           | rebase the last 3 commits, stashing local changes                                                         |
| `git commit --fixup=<sha>`        | the next `grb` squashes it into that commit                                                               |
| `tig` · `gh pr create`            | history browser · GitHub CLI                                                                              |
| automatic                         | zdiff3 conflicts · rerere · recent branches first                                                         |
| diffs                             | delta: syntax colors and line numbers; `n` / `N` jump between files; side by side: `git diff \| delta -s` |

## Docker and Kubernetes

| Command                | What it does                                            |
|------------------------|---------------------------------------------------------|
| `dc up -d` · `dc ps`   | docker compose; `ps` as a compact table                 |
| `dcr api` · `dcrb api` | restart + logs · recreate (removes volumes) + logs      |
| `dnet postgres`        | live network traffic of a container                     |
| `k get pods` · `k9s`   | kubectl · cluster UI, both use ./.kubeconfig if present |
| `helm list -A`         | Kubernetes packages                                     |

## Go

| Command                          | What it does                                            |
|----------------------------------|---------------------------------------------------------|
| `goenv /opt 1.25.0`              | switch Go version; downloads and verifies it if missing |
| `gotest` · `gobench` · `goclean` | race tests ./... · benchmarks · clear caches            |
| `goinstall pkg@latest`           | go install bypassing the module proxy                   |

## AI agents (no permission prompts)

| Command                                  | What it does                              |
|------------------------------------------|-------------------------------------------|
| `clauded` · `coded` · `agyd` · `crushed` | Claude Code · Codex · Antigravity · Crush |

## Remote hosts

| Command                                 | What it does                                                                                      |
|-----------------------------------------|---------------------------------------------------------------------------------------------------|
| `hop server`                            | session "main" over mosh if possible, else ssh; in zellij, tmux or screen, whichever the host has |
| `hop --ssh server`                      | skip mosh, e.g. when the host's firewall blocks UDP 60000-61000                                   |
| `Enter` then `~.`                       | end a frozen ssh session immediately                                                              |
| `Ctrl-^` then `.`                       | quit a mosh that hangs on "Connecting…"                                                           |
| `term-reset`                            | fix a window that prints garbage on mouse moves; keeps the scrollback, unlike `reset`             |
| `Ctrl-B` then `p` · `t` · `s` · `o`     | zellij: panes · tabs · scroll and search · sessions                                               |
| `Ctrl-B` `p` then `r` · `d` · `x` · `f` | zellij pane: new right · new below · close · fullscreen                                           |
| `Ctrl-B` `o` then `d`                   | leave zellij; the session keeps running                                                           |

## Tools

| Command                       | What it does                                    |
|-------------------------------|-------------------------------------------------|
| `mc`                          | file manager; quitting leaves you in its folder |
| `broot`                       | tree navigator; `broot --install` adds `br`     |
| `dc logs -f \| gonzo`         | log analysis UI                                 |
| `posting`                     | HTTP client UI                                  |
| `jq` · `yq`                   | query JSON · YAML                               |
| `hf 'cmd'` · `watch -n 5 cmd` | benchmark · repeat a command                    |

## Automatic

| Feature | What it does                                                     |
|---------|------------------------------------------------------------------|
| direnv  | a folder's .envrc loads on cd; approve with `direnv allow`       |
| history | 100k lines shared by all shells; a leading space skips saving    |
| ssh     | connections to a host are reused for 10 minutes                  |
| ssh     | a dead link drops after ~45 s; the terminal is reset after drops |
| nano    | each save keeps a backup in ~/.local/state/nano/backups          |

## Your settings (setup never overwrites)

| Where                        | What goes there                                            |
|------------------------------|------------------------------------------------------------|
| `~/.gitconfig.local`         | personal git settings; GPG and SSH signing examples inside |
| `~/.ssh/config_hosts`        | ssh hosts; override the defaults                           |
| `~/.zshrc`, `~/.zsh_aliases` | your lines outside the UNIXENV block                       |
| `*.<timestamp>.bak`          | the last 5 versions of each replaced config                |

## Misc

| Command                  | What it does                                                                    |
|--------------------------|---------------------------------------------------------------------------------|
| `cheat` · `unixenv`      | this page · re-run setup (setup.light on hosts set up without Homebrew)         |
| `ss`                     | random terminal screensaver                                                     |
| `power on` · `power off` | macOS deep sleep off · back on (sudo)                                           |
| `rmdsstore`              | delete .DS_Store under /opt (macOS, sudo)                                       |
| `motd-quiet`             | turn off Ubuntu's login messages, keep the reboot-required notice (Linux, sudo) |
| `gogh` · `gogek`         | terminal color schemes · gogek on :8888                                         |
| `c` · `xx` · `..`        | clear · exit · cd ..                                                            |
