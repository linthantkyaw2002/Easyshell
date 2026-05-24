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

timestamp() {
    date +%Y%m%d_%H%M%S
}

ask_yes_no() {
    local prompt="$1"
    local answer=""

    # Non-interactive shell: default to NO.
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
    cp "$file" "$file.flow_backup.$(timestamp)"
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
    ' "$file" > "$file.tmp.$$" && mv "$file.tmp.$$" "$file"
}

clean_shell_file() {
    local file="$1"

    [ -f "$file" ] || return 0
    backup_file "$file"

    remove_managed_block "$file" "$FLOW_BLOCK_BEGIN" "$FLOW_BLOCK_END"
    remove_managed_block "$file" "$FLOW_BASH_LOADER_BEGIN" "$FLOW_BASH_LOADER_END"

    # Remove known old Flow fragments and bad leftovers.
    awk '
        /source[[:space:]]+["'"'"']?\$HOME\/\.flow\/hooks\/flow\.(bash|zsh)["'"'"']?/ { next }
        /source[[:space:]]+["'"'"']?~\/\.flow\/hooks\/flow\.(bash|zsh)["'"'"']?/ { next }

        /# --- Flow Automation Hook/ { next }
        /Flow Automation Hook/ { next }

        /__flow_bash_capture/ { next }
        /__flow_bash_debug_trap/ { next }
        /__flow_zsh_preexec/ { next }
        /__flow_should_skip_cmd/ { next }
        /__flow_clean_cmd/ { next }
        /__flow_record_from_zsh_history/ { next }
        /__flow_bash_prompt_reset/ { next }
        /__flow_last_cmd/ { next }
        /__flow_last_zsh_cmd/ { next }
        /__flow_internal_guard/ { next }
        /__FLOW_INTERNAL_TRAP/ { next }

        /^[[:space:]]*local[[:space:]]+cmd[[:space:]]*$/ { next }
        /^[[:space:]]*cmd="\$BASH_COMMAND"[[:space:]]*$/ { next }
        /^[[:space:]]*cmd=\$BASH_COMMAND[[:space:]]*$/ { next }
        /^[[:space:]]*command[[:space:]]+flow[[:space:]]+_hook/ { next }
        /^[[:space:]]*trap[[:space:]]+-[[:space:]]+DEBUG[[:space:]]*$/ { next }
        /^[[:space:]]*trap[[:space:]]*'\''__flow_bash_debug_trap'\''[[:space:]]+DEBUG[[:space:]]*$/ { next }
        /trap '\''flow _hook "\$BASH_COMMAND"/ { next }

        { print }
    ' "$file" > "$file.tmp.$$" && mv "$file.tmp.$$" "$file"
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
    echo "🧹 Cleaning shell startup files..."

    for file in \
        "$HOME/.bashrc" \
        "$HOME/.bash_profile" \
        "$HOME/.bash_login" \
        "$HOME/.profile" \
        "$HOME/.zshrc" \
        "$HOME/.zprofile" \
        "$HOME/.zshenv"
    do
        clean_shell_file "$file"
    done
}

remove_flow_home() {
    if [ -d "$FLOW_HOME" ]; then
        rm -rf "$FLOW_HOME"
        echo "✅ Removed $FLOW_HOME"
    else
        echo "ℹ️ Flow config/hooks directory not found at $FLOW_HOME"
    fi
}

remove_temp_files() {
    rm -f /tmp/.flow_active_state
    rm -f /tmp/.flow_record_cache
    rm -f /tmp/.flow_recorded_path
    rm -f /tmp/.flow_execution_wrapper.sh
    echo "✅ Removed Flow temp files"
}

handle_saved_builds() {
    echo ""
    echo "Flow saved builds are your recorded workflows created by:"
    echo "  flow build <name>"
    echo ""
    echo "Saved builds location:"
    echo "  $FLOW_MACROS_DIR"
    echo ""

    if [ ! -d "$FLOW_MACROS_DIR" ]; then
        echo "ℹ️ No saved Flow builds found at $FLOW_MACROS_DIR"
        return 0
    fi

    # Explicit environment override for scripts/CI.
    if [ "${FLOW_DELETE_MACROS:-}" = "1" ]; then
        rm -rf "$FLOW_MACROS_DIR"
        echo "✅ Removed saved Flow builds: $FLOW_MACROS_DIR"
        return 0
    fi

    if [ "${FLOW_DELETE_MACROS:-}" = "0" ]; then
        echo "ℹ️ Kept saved Flow builds at $FLOW_MACROS_DIR"
        return 0
    fi

    if ask_yes_no "Do you also want to delete all saved Flow builds?"; then
        rm -rf "$FLOW_MACROS_DIR"
        echo "✅ Removed saved Flow builds: $FLOW_MACROS_DIR"
    else
        echo "ℹ️ Kept saved Flow builds at $FLOW_MACROS_DIR"
    fi
}

cleanup_current_session_hint() {
    cat <<'EOF'

Important: this script cleans future shells, not the already-running parent shell.
After uninstall, close/reopen the terminal or run the matching command below.

For current Bash:
  trap - DEBUG
  unset PROMPT_COMMAND
  unset -f __flow_bash_capture __flow_bash_debug_trap 2>/dev/null
  unset __FLOW_INTERNAL_TRAP

For current Zsh:
  preexec_functions=(${preexec_functions:#__flow_zsh_preexec})
  unfunction __flow_zsh_preexec 2>/dev/null
EOF
}

main() {
    echo "🧨 Uninstalling Flow..."
    echo ""

    remove_binary
    remove_shell_hooks
    remove_flow_home
    remove_temp_files
    handle_saved_builds

    echo ""
    echo "✅ Flow uninstall complete."
    echo "Dotfile backups were kept as *.flow_backup.TIMESTAMP files."
    cleanup_current_session_hint
}

main "$@"
