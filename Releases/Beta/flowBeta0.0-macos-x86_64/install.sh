#!/usr/bin/env bash
set -euo pipefail

APP_NAME="flow"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_BIN="$SCRIPT_DIR/$APP_NAME"
INSTALL_DIR="${FLOW_INSTALL_DIR:-/usr/local/bin}"
HOOK_DIR="$HOME/.flow/hooks"

FLOW_BLOCK_BEGIN="# >>> Flow hook >>>"
FLOW_BLOCK_END="# <<< Flow hook <<<"
FLOW_BASH_LOADER_BEGIN="# >>> Flow bash loader >>>"
FLOW_BASH_LOADER_END="# <<< Flow bash loader <<<"

if [ ! -f "$SRC_BIN" ]; then
    echo "❌ Cannot find compiled '$APP_NAME' binary next to this installer."
    echo "Expected: $SRC_BIN"
    echo "Build first, then put install.sh beside the flow binary."
    exit 1
fi

mkdir -p "$HOOK_DIR"

echo "📦 Installing $APP_NAME to $INSTALL_DIR..."
if [ -w "$INSTALL_DIR" ]; then
    install -m 755 "$SRC_BIN" "$INSTALL_DIR/$APP_NAME"
else
    sudo mkdir -p "$INSTALL_DIR"
    sudo install -m 755 "$SRC_BIN" "$INSTALL_DIR/$APP_NAME"
fi

cat > "$HOOK_DIR/flow.zsh" <<'ZSH_HOOK'
# --- Flow Automation Hook: zsh ---
# Captures interactive zsh commands before execution.

__flow_zsh_preexec() {
    local cmd="$1"

    [[ -z "$cmd" ]] && return

    case "$cmd" in
        flow|flow\ *|command\ flow|command\ flow\ *) return ;;
        source\ *~/.flow/hooks/flow.zsh*) return ;;
        source\ *\$HOME/.flow/hooks/flow.zsh*) return ;;
    esac

    command flow _hook "$cmd" >/dev/null 2>&1
}

autoload -Uz add-zsh-hook
add-zsh-hook -d preexec __flow_zsh_preexec 2>/dev/null || true
add-zsh-hook preexec __flow_zsh_preexec
ZSH_HOOK

cat > "$HOOK_DIR/flow.bash" <<'BASH_HOOK'
# --- Flow Automation Hook: bash ---
# Captures interactive bash commands before execution.
# Bash has no native preexec hook, so Flow uses DEBUG trap.

# Remove older Flow PROMPT_COMMAND hook if a previous version installed it.
unset -f __flow_bash_capture 2>/dev/null || true

if [ -n "${PROMPT_COMMAND:-}" ]; then
    PROMPT_COMMAND="$(printf '%s\n' "$PROMPT_COMMAND" \
        | sed 's/__flow_bash_capture;*//g; s/;;*/;/g; s/^;//; s/;$//')"
    [ -z "$PROMPT_COMMAND" ] && unset PROMPT_COMMAND
fi

__flow_bash_debug_trap() {
    local cmd="$BASH_COMMAND"

    # Avoid recursively recording commands executed by this hook itself.
    trap - DEBUG

    case "$cmd" in
        "") ;;
        flow|flow\ *|command\ flow|command\ flow\ *) ;;
        __flow_*) ;;
        trap\ *) ;;
        source\ *~/.flow/hooks/flow.bash*) ;;
        source\ *\$HOME/.flow/hooks/flow.bash*) ;;
        .\ *~/.flow/hooks/flow.bash*) ;;
        .\ *\$HOME/.flow/hooks/flow.bash*) ;;
        PROMPT_COMMAND=*) ;;
        unset\ PROMPT_COMMAND*) ;;
        unset\ -f\ __flow_*) ;;
        *) command flow _hook "$cmd" >/dev/null 2>&1 ;;
    esac

    trap '__flow_bash_debug_trap' DEBUG
}

trap '__flow_bash_debug_trap' DEBUG
BASH_HOOK

backup_file() {
    local file="$1"

    [ -f "$file" ] || return 0
    cp "$file" "$file.flow_backup"
}

remove_managed_block() {
    local file="$1"
    local begin="$2"
    local end="$3"

    [ -f "$file" ] || return 0
    awk -v begin="$begin" -v end="$end" '
        $0 == begin { skip = 1; next }
        $0 == end { skip = 0; next }
        !skip { print }
    ' "$file" > "$file.tmp" && mv "$file.tmp" "$file"
}

remove_legacy_flow_lines() {
    local file="$1"

    [ -f "$file" ] || return 0
    backup_file "$file"

    remove_managed_block "$file" "$FLOW_BLOCK_BEGIN" "$FLOW_BLOCK_END"
    remove_managed_block "$file" "$FLOW_BASH_LOADER_BEGIN" "$FLOW_BASH_LOADER_END"

    awk '
        /source[[:space:]]+["'"'"']?\$HOME\/\.flow\/hooks\/flow\.(zsh|bash)["'"'"']?/ { next }
        /source[[:space:]]+["'"'"']?~\/\.flow\/hooks\/flow\.(zsh|bash)["'"'"']?/ { next }
        /preexec\(\)[[:space:]]*\{[[:space:]]*flow _hook "\$1"/ { next }
        /trap '\''flow _hook "\$BASH_COMMAND"/ { next }
        /__flow_bash_capture/ { next }
        /__flow_zsh_preexec/ { next }
        /# --- Flow Automation Hook ---/ { next }
        { print }
    ' "$file" > "$file.tmp" && mv "$file.tmp" "$file"
}

append_managed_block() {
    local file="$1"
    local begin="$2"
    local body="$3"
    local end="$4"

    touch "$file"
    remove_managed_block "$file" "$begin" "$end"
    {
        printf '\n%s\n' "$begin"
        printf '%s\n' "$body"
        printf '%s\n' "$end"
    } >> "$file"
    echo "✅ Added Flow hook to $file"
}

for file in \
    "$HOME/.zshrc" \
    "$HOME/.zprofile" \
    "$HOME/.zshenv" \
    "$HOME/.bashrc" \
    "$HOME/.bash_profile"
do
    remove_legacy_flow_lines "$file"
done

append_managed_block \
    "$HOME/.zshrc" \
    "$FLOW_BLOCK_BEGIN" \
    '[ -f "$HOME/.flow/hooks/flow.zsh" ] && source "$HOME/.flow/hooks/flow.zsh"' \
    "$FLOW_BLOCK_END"

append_managed_block \
    "$HOME/.bashrc" \
    "$FLOW_BLOCK_BEGIN" \
    '[ -f "$HOME/.flow/hooks/flow.bash" ] && source "$HOME/.flow/hooks/flow.bash"' \
    "$FLOW_BLOCK_END"

# macOS login bash may read ~/.bash_profile instead of ~/.bashrc.
append_managed_block \
    "$HOME/.bash_profile" \
    "$FLOW_BASH_LOADER_BEGIN" \
    '[ -f "$HOME/.bashrc" ] && source "$HOME/.bashrc"' \
    "$FLOW_BASH_LOADER_END"

echo ""
echo "✅ Flow installed successfully."
echo ""
echo "Restart your terminal, or run one of these:"
echo "  exec zsh     # reload zsh"
echo "  exec bash    # reload bash"
echo ""
echo "Test:"
echo "  flow start"
echo "  echo hello"
echo "  flow stop"
echo "  flow list"
echo ""
echo "Uninstall later with:"
echo "  ./uninstall.sh"
