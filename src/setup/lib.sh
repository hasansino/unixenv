# Shared steps of `setup` (Homebrew) and `setup.light` (mise, no sudo), sourced by both.
# Each entry script defines usage(), installs its tools, then runs the steps below; shell files last.

REPO_URL="https://github.com/hasansino/unixenv.git"
CLONE_DIR="$HOME/unixenv"
RUN_FONTS=false
RUN_UPDATE=true

# parse_args <fonts|no-fonts> "$@": --fonts is accepted only by entries that install fonts
# shellcheck disable=SC2034 # RUN_FONTS is read by setup
parse_args() {
    local fonts_allowed="$1"
    shift
    local arg
    for arg in "$@"; do
        case "$arg" in
            --no-update) RUN_UPDATE=false ;;
            --fonts)
                if [ "$fonts_allowed" != fonts ]; then
                    echo "Error: unknown option: $arg" >&2
                    usage >&2
                    exit 2
                fi
                RUN_FONTS=true
                ;;
            -h | --help)
                usage
                exit 0
                ;;
            *)
                echo "Error: unknown option: $arg" >&2
                usage >&2
                exit 2
                ;;
        esac
    done
}

# check_prerequisites [command...]: a normal user, a supported OS, git, and the given commands
check_prerequisites() {
    if [ "$(id -u)" -eq 0 ]; then
        echo "Error: running from root is not allowed." >&2
        exit 1
    fi
    local tool
    for tool in git "$@"; do
        if ! command -v "$tool" > /dev/null 2>&1; then
            echo "Error: $tool is required, but not installed." >&2
            exit 1
        fi
    done
    case "$OSTYPE" in
        darwin*) echo "OS: darwin" ;;
        linux-gnu) echo "OS: linux" ;;
        *)
            echo "Error: unsupported OS: $OSTYPE" >&2
            exit 1
            ;;
    esac
}

# Clone, or fast-forward master; a clone on another branch or with local changes is left alone.
update_clone() {
    if [ ! -d "$CLONE_DIR" ]; then
        echo "Cloning git repo..."
        git clone "$REPO_URL" "$CLONE_DIR"
        return
    fi
    local branch
    branch="$(git -C "$CLONE_DIR" symbolic-ref --short -q HEAD || true)"
    if [ "$branch" != "master" ]; then
        echo "Skipping update: $CLONE_DIR is on ${branch:-a detached HEAD}, not master."
    elif [ -n "$(git -C "$CLONE_DIR" status --porcelain)" ]; then
        echo "Skipping update: $CLONE_DIR has uncommitted changes."
    else
        echo "Updating git repo..."
        git -C "$CLONE_DIR" pull --ff-only origin master
    fi
}

# self_update <script> "$@": update the clone, and start <script> again when that brought new commits,
# since this shell already holds the previous version of the script and of this file.
self_update() {
    local script="$1"
    shift
    if [ "$RUN_UPDATE" != true ]; then
        if [ ! -d "$CLONE_DIR" ]; then
            echo "Error: $CLONE_DIR not found, --no-update needs an existing clone." >&2
            exit 1
        fi
        return 0
    fi
    local before after
    before=$(git -C "$CLONE_DIR" rev-parse HEAD 2> /dev/null || true)
    update_clone
    after=$(git -C "$CLONE_DIR" rev-parse HEAD)
    if [ -n "$before" ] && [ "$before" != "$after" ]; then
        echo "unixenv has been updated. Restarting..."
        exec "$script" "$@"
    fi
}

# work in a temporary directory, removed on exit
enter_tmp_dir() {
    TMP_DIR=$(mktemp -d)
    cd "$TMP_DIR" || exit 1
    trap 'rm -rf "$TMP_DIR"' EXIT
}

# --- files ---

# update_file <content> <target>: write content between the UNIXENV markers, keeping lines around them
update_file() {
    local header="#_____UNIXENV_CONFIG_START____"
    local footer="#_____UNIXENV_CONFIG_END______"
    local source="$1"
    local target="$2"

    local block_file
    block_file=$(mktemp)
    printf "%s\n%s\n%s\n" "$header" "$source" "$footer" > "$block_file"

    if [ -f "$target" ] && grep -qF "$header" "$target" && grep -qF "$footer" "$target"; then
        # replace block in place, so lines before/after it keep their position
        local tmp_file
        tmp_file=$(mktemp)
        awk -v header="$header" -v footer="$footer" '
            NR == FNR { block = block $0 "\n"; next }
            index($0, header) { if (!done) printf "%s", block; done = 1; skip = 1; next }
            skip { if (index($0, footer)) skip = 0; next }
            { print }
        ' "$block_file" "$target" > "$tmp_file"
        cat "$tmp_file" > "$target"
        rm "$tmp_file"
    else
        cat "$block_file" >> "$target"
    fi
    rm "$block_file"
}

# copy a file to <file>.<timestamp>.bak, keeping only the newest BACKUPS_KEPT copies
BACKUPS_KEPT=5
backup_file() {
    local target="$1"
    local backup
    backup="$target.$(date +%Y%m%d-%H%M%S).bak"
    cp "$target" "$backup"
    echo "Backed up $target to $backup"
    # the glob sorts by name, which is oldest first for these timestamps
    local backups=("$target".*.bak)
    local excess=$((${#backups[@]} - BACKUPS_KEPT))
    if [ "$excess" -gt 0 ]; then
        rm -f "${backups[@]:0:excess}"
    fi
}

# copy a config file, backing up the previous version when it differs
install_config() {
    local source="$1"
    local target="$2"

    mkdir -p "$(dirname "$target")"
    if [ -f "$target" ] && ! cmp -s "$source" "$target"; then
        backup_file "$target"
    fi
    cp "$source" "$target"
}

# --- where tools live, whichever package manager installed them ---

# tool_prefix <tool>: the folder a tool is installed in (above its bin folder); fails when missing.
# mise is asked first: its shims are links to mise itself, not to the tool.
tool_prefix() {
    local path
    if command -v mise > /dev/null 2>&1 && path=$(mise which "$1" 2> /dev/null) && [ -n "$path" ]; then
        :
    elif path=$(command -v "$1" 2> /dev/null); then
        path=$(readlink -f "$path")
    else
        return 1
    fi
    dirname "$(dirname "$path")"
}

# stable_prefix <prefix>: the same install with the version swapped for the link its package manager
# keeps across upgrades, so configs that name it keep working: brew's opt/<name>, mise's <tool>/latest.
# Anything else (/usr) is already stable.
stable_prefix() {
    local prefix="$1" rest
    case "$prefix" in
        */Cellar/*/*)
            rest="${prefix#*/Cellar/}"
            echo "${prefix%%/Cellar/*}/opt/${rest%%/*}"
            ;;
        */mise/installs/*/*)
            rest="${prefix#*/mise/installs/}"
            echo "${prefix%%/mise/installs/*}/mise/installs/${rest%%/*}/latest"
            ;;
        *) echo "$prefix" ;;
    esac
}

# --- pinned downloads (src/pinned/pinned.toml) ---

sha256_of() {
    if command -v sha256sum > /dev/null 2>&1; then
        sha256sum "$1" | awk '{ print $1 }'
    else
        shasum -a 256 "$1" | awk '{ print $1 }'
    fi
}

# Download a release binary (or a .tar.gz holding one), check it against the recorded checksum and
# install it into ~/.local/bin. A failure only skips that binary.
install_release_binary() {
    local name="$1" url="$2" sha256="$3"
    local dir binary
    dir=$(mktemp -d)
    if ! curl -fsSL -o "$dir/download" "$url"; then
        echo "Warning: could not download $url; skipping $name." >&2
        rm -rf "$dir"
        return 0
    fi
    if [ "$(sha256_of "$dir/download")" != "$sha256" ]; then
        echo "Warning: checksum mismatch for $url; skipping $name." >&2
        rm -rf "$dir"
        return 0
    fi
    binary="$dir/download"
    if [[ "$url" == *.tar.gz ]]; then
        mkdir "$dir/unpacked"
        tar -xzf "$dir/download" -C "$dir/unpacked"
        # the archives hold the binary alone, under a path that differs per release
        binary=$(find "$dir/unpacked" -type f | head -n 1)
    fi
    mkdir -p "$HOME/.local/bin"
    install -m 755 "$binary" "$HOME/.local/bin/$name"
    rm -rf "$dir"
}

# pin <name>: "<url> <sha256>" of a pinned download for this platform, from src/pinned/pinned.toml;
# fails when that release has no build for this platform.
# Reads the file's fixed layout (formatted by tombi) with awk, so setup needs no TOML parser:
# [<name>] with repo and tag, then [<name>.files] with "<platform>" = { file = …, sha256 = … }.
pin() {
    local platform
    platform="$(uname -s)/$(uname -m)"
    if [ "$platform" = Linux/arm64 ]; then
        platform=Linux/aarch64
    fi
    awk -v name="$1" -v platform="$platform" '
        function string(line, key,    s) {
            if (!match(line, key " = \"[^\"]*\"")) return ""
            s = substr(line, RSTART, RLENGTH)
            sub(/^[^"]*"/, "", s)
            sub(/"$/, "", s)
            return s
        }
        /^\[/ { section = $0; gsub(/[][ ]/, "", section); next }
        section == name { if (/^repo = /) repo = string($0, "repo"); if (/^tag = /) tag = string($0, "tag") }
        section == name ".files" && /=/ && file == "" {
            key = $0
            sub(/ =.*/, "", key)
            gsub(/"/, "", key)
            if (key == platform || key == "any") {
                file = string($0, "file")
                sha256 = string($0, "sha256")
            }
        }
        END {
            if (repo == "" || tag == "" || file == "") exit 1
            version = tag
            sub(/^v/, "", version)
            # plain string functions: awks differ on braces in regular expressions
            i = index(file, "{version}")
            if (i) file = substr(file, 1, i - 1) version substr(file, i + 9)
            print "https://github.com/" repo "/releases/download/" tag "/" file, sha256
        }
    ' "$CLONE_DIR/src/pinned/pinned.toml"
}

# --- configuration ---

configs() {
    # ssh
    install_config "$CLONE_DIR/src/generic/config/ssh/config" "$HOME/.ssh/config"
    touch "$HOME/.ssh/config_hosts"
    # git
    install_config "$CLONE_DIR/src/generic/config/gitconfig" "$HOME/.gitconfig"
    install_config "$CLONE_DIR/src/generic/config/gitignore" "$HOME/.gitignore"
    # btm
    install_config "$CLONE_DIR/src/generic/config/btm.toml" "$HOME/.config/btm.toml"
    # htop
    install_config "$CLONE_DIR/src/generic/config/htop/htoprc" "$HOME/.config/htop/htoprc"
    # eza
    install_config "$CLONE_DIR/src/generic/config/eza/theme.yml" "$HOME/.config/eza/theme.yml"
    # ripgrep, through RIPGREP_CONFIG_PATH in the shell rc
    install_config "$CLONE_DIR/src/generic/config/ripgrep/config" "$HOME/.config/ripgrep/config"
    # zellij for local use; hop passes the same keys on the command line, so hosts need no config
    install_config "$CLONE_DIR/src/generic/config/zellij/config.kdl" "$HOME/.config/zellij/config.kdl"
    # generic
    touch "$HOME/.hushlogin"
    # a bit more complicated cases
    config_nano
    config_docker
    config_mc
}

config_nano() {
    # nanorc cannot read $HOME or ask where nano is installed, so setup adds both paths here.
    # Backups live outside /tmp, which the system cleans; nano does not start when backupdir is missing.
    local backup_dir="$HOME/.local/state/nano/backups"
    local prefix syntax_dir=""
    if prefix=$(tool_prefix nano); then
        syntax_dir="$(stable_prefix "$prefix")/share/nano"
    fi
    local tmp
    tmp=$(mktemp)
    mkdir -p "$backup_dir"
    cat "$CLONE_DIR/src/generic/config/nanorc" > "$tmp"
    printf 'set backupdir "%s"\n' "$backup_dir" >> "$tmp"
    if [ -n "$syntax_dir" ] && [ -d "$syntax_dir" ]; then
        printf '\n# syntax highlighting shipped with nano, added by setup\ninclude "%s/*.nanorc"\n' "$syntax_dir" >> "$tmp"
    fi
    chmod 644 "$tmp" # mktemp creates 600, and cp gives a new file the source mode
    install_config "$tmp" "$HOME/.nanorc"
    rm "$tmp"
}

config_docker() {
    local CONFIG_DIR="$HOME/.docker"
    local CONFIG_FILE="$CONFIG_DIR/config.json"
    local GENERIC_CONFIG="$CLONE_DIR/src/generic/config/docker/config.json"

    if ! command -v jq > /dev/null 2>&1; then
        echo "config_docker warning: jq is not installed; skipping the docker config." >&2
        return 0
    fi

    mkdir -p "$CONFIG_DIR"

    if [ ! -f "$CONFIG_FILE" ]; then
        cp "$GENERIC_CONFIG" "$CONFIG_FILE"
        echo "Created $CONFIG_FILE from $GENERIC_CONFIG"
    else
        local tmp
        tmp=$(mktemp)
        if ! jq -s '.[0] * .[1]' "$CONFIG_FILE" "$GENERIC_CONFIG" > "$tmp"; then
            echo "config_docker warning: $CONFIG_FILE is not valid JSON, left unchanged." >&2
            rm -f "$tmp"
            return 0
        fi
        # jq reformats the file, so compare parsed JSON: back up and replace only when a value changes
        if jq -e --slurpfile merged "$tmp" '. == $merged[0]' "$CONFIG_FILE" > /dev/null; then
            rm "$tmp"
        else
            backup_file "$CONFIG_FILE"
            mv "$tmp" "$CONFIG_FILE"
            echo "Merged $GENERIC_CONFIG into $CONFIG_FILE"
        fi
    fi
}

config_mc() {
    local CONFIG_DIR="$HOME/.config/mc"
    local SOURCE_DIR="$CLONE_DIR/src/generic/config/mc"

    install_config "$SOURCE_DIR/ini" "$CONFIG_DIR/ini"

    if ! command -v mc > /dev/null 2>&1; then
        echo "config_mc warning: mc is not installed; skipping its file actions." >&2
        return 0
    fi
    # mc reports where it keeps its default file actions; the first "Config directory" is the system one
    local system_dir
    system_dir=$(mc -F 2> /dev/null | awk -F': *' '/Config directory/ { print $2; exit }')
    system_dir="${system_dir%/}"
    if [ ! -f "$system_dir/mc.ext.ini" ]; then
        echo "config_mc warning: mc's default file actions not found; skipping them." >&2
        return 0
    fi
    # mc reads only the user extension file once it exists, so ours is followed by the system rules.
    # Those name mc's versioned install folder, which upgrades remove; point them at the stable link.
    local prefix="${system_dir%/etc/mc}"
    local stable
    stable=$(stable_prefix "$prefix")
    local tmp
    tmp=$(mktemp)
    {
        cat "$SOURCE_DIR/mc.ext.ini"
        if [ -n "$prefix" ] && [ "$prefix" != "$stable" ]; then
            sed "s|$prefix/|$stable/|g" "$system_dir/mc.ext.ini"
        else
            cat "$system_dir/mc.ext.ini"
        fi
    } > "$tmp"
    chmod 644 "$tmp" # mktemp creates 600, and cp gives a new file the source mode
    install_config "$tmp" "$CONFIG_DIR/mc.ext.ini"
    rm "$tmp"
}

scripts() {
    mkdir -p "$HOME/.local/bin"
    ln -sf "$CLONE_DIR/src/bin/goenv-scp" "$HOME/.local/bin/goenv-scp" # alias `goenv`
    ln -sf "$CLONE_DIR/src/bin/cheat" "$HOME/.local/bin/cheat"
    ln -sf "$CLONE_DIR/src/bin/hop" "$HOME/.local/bin/hop"
    ln -sf "$CLONE_DIR/src/bin/term-reset" "$HOME/.local/bin/term-reset"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        ln -sf "$CLONE_DIR/src/bin/power" "$HOME/.local/bin/power"
    else
        ln -sf "$CLONE_DIR/src/bin/motd-quiet" "$HOME/.local/bin/motd-quiet"
    fi
}

# Shell files go last: they call the installed tools and expect the installed configs,
# so a failed install leaves the previous, working shell setup in place.
shell_files() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        update_file "$(cat "$CLONE_DIR/src/macos/zprofile")" "$HOME/.zprofile"
        update_file "$(cat "$CLONE_DIR/src/generic/rc" "$CLONE_DIR/src/macos/zshrc")" "$HOME/.zshrc"
        update_file "$(cat "$CLONE_DIR/src/macos/zsh_aliases" "$CLONE_DIR/src/generic/aliases")" "$HOME/.zsh_aliases"
    else
        update_file "$(cat "$CLONE_DIR/src/linux/bash_profile")" "$HOME/.bash_profile"
        update_file "$(cat "$CLONE_DIR/src/generic/rc" "$CLONE_DIR/src/linux/bashrc")" "$HOME/.bashrc"
        update_file "$(cat "$CLONE_DIR/src/linux/bash_aliases" "$CLONE_DIR/src/generic/aliases")" "$HOME/.bash_aliases"
    fi
}
