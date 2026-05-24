#!/usr/bin/env bash
set -euo pipefail

APP_NAME="flow"
INSTALL_DIR="${FLOW_INSTALL_DIR:-/usr/local/bin}"
FLOW_BIN="$INSTALL_DIR/$APP_NAME"
FLOW_HOME="$HOME/.flow"
FLOW_MACROS_DIR="$HOME/.flow_macros"

FLOW_BLOCK_BEGIN="# >>> Flow hook >>>"
FLOW_BLOCK_END="# <<< Flow hook <<<"
FLOW_BASH_LOADER_BEGIN="# >>> Flow bash loader >>>"
FLOW_BASH_LOADER_END="# <<< Flow bash loader <<<"

ask_yes_no() {
    local prompt="$1"
    local answer=""

    if [ ! -t 0 ]; then
        return 1
    fi

    printf "%s [y/N]: " "$prompt"
    read -r answer || return 1
    case "$answer" in
        y|Y|yes|YES|Yes) return 0 ;;
        *) return 1 ;;
    esac
}

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
        /\[ -f "\$HOME\/\.bashrc" \] && source "\$HOME\/\.bashrc"/ { next }
        /preexec\(\)[[:space:]]*\{[[:space:]]*flow _hook "\$1"/ { next }
        /trap '\''flow _hook "\$BASH_COMMAND"/ { next }
        /__flow_bash_capture/ { next }
        /__flow_bash_debug_trap/ { next }
        /__flow_zsh_preexec/ { next }
        /# --- Flow Automation Hook ---/ { next }
        { print }
    ' "$file" > "$file.tmp" && mv "$file.tmp" "$file"
}

remove_binary() {
    if [ -f "$FLOW_BIN" ]; then
        if [ -w "$(dirname "$FLOW_BIN")" ]; then
            rm -f "$FLOW_BIN"
        else
            sudo rm -f "$FLOW_BIN"
        fi
        echo "✅ Removed $FLOW_BIN"
    else
        echo "ℹ️ Flow binary not found at $FLOW_BIN"
    fi
}

remove_shell_hooks() {
    for file in \
        "$HOME/.zshrc" \
        "$HOME/.zprofile" \
        "$HOME/.zshenv" \
        "$HOME/.bashrc" \
        "$HOME/.bash_profile"
    do
        remove_legacy_flow_lines "$file"
    done
}

remove_flow_home() {
    if [ -d "$FLOW_HOME" ]; then
        rm -rf "$FLOW_HOME"
        echo "✅ Removed $FLOW_HOME"
    else
        echo "ℹ️ Flow config directory not found at $FLOW_HOME"
    fi
}

remove_temp_files() {
    rm -f /tmp/.flow_active_state
    rm -f /tmp/.flow_record_cache
    rm -f /tmp/.flow_recorded_path
    rm -f /tmp/.flow_execution_wrapper.sh
    echo "✅ Removed Flow temp files"
}

remove_saved_builds() {
    if [ -d "$FLOW_MACROS_DIR" ]; then
        rm -rf "$FLOW_MACROS_DIR"
        echo "✅ Removed saved Flow builds: $FLOW_MACROS_DIR"
    else
        echo "ℹ️ No saved Flow builds found at $FLOW_MACROS_DIR"
    fi
}

cleanup_current_session_hint() {
    cat <<'EOS'

If your current Bash session still has old hooks loaded, run:
  trap - DEBUG
  unset PROMPT_COMMAND
  unset -f __flow_bash_capture __flow_bash_debug_trap 2>/dev/null

If your current Zsh session still has old hooks loaded, run:
  preexec_functions=(${preexec_functions:#__flow_zsh_preexec})
  unfunction __flow_zsh_preexec 2>/dev/null
EOS
}

echo "🧹 Uninstalling Flow..."
echo ""

remove_binary
remove_shell_hooks
remove_flow_home
remove_temp_files

echo ""
echo "Flow saved builds are stored separately from the Flow program."
echo "These are the workflows created by: flow build <name>"
echo "Location: $FLOW_MACROS_DIR"
echo ""
if ask_yes_no "Do you also want to delete all saved Flow builds?"; then
    remove_saved_builds
else
    echo "ℹ️ Kept saved Flow builds at $FLOW_MACROS_DIR"
fi

echo ""
echo "✅ Flow uninstalled successfully."
echo ""
echo "Restart your terminal, or run one of these:"
echo "  exec zsh     # if you are in zsh"
echo "  exec bash    # if you are in bash"
cleanup_current_session_hint
