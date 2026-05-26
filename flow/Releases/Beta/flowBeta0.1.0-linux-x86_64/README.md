# Flow CLI Tool

**Flow** is a lightweight command workflow recorder and runner for Unix-like shells. It helps developers record terminal command sequences, save them as reusable named builds, replay them later, and recover deleted builds through a local recycling bin.

Flow is designed for repetitive terminal workflows such as building, testing, cleaning, running programs, copying project files, or replaying common development commands.

```bash
make fclean
make
./program
```

Instead of typing the same sequence again and again, Flow lets you record it once and replay it whenever needed.

---

## Project Information

| Item              | Details                                                                          |
|-------------------|----------------------------------------------------------------------------------|
| Project Name      | Flow CLI Tool                                                                    |
| Release Type      | Beta                                                                             |
| Author            | Lin Thant Kyaw                                                                   |
| Repository        | https://github.com/linthantkyaw2002/Easyshell/tree/main/flow                     |
| Issues            | https://github.com/linthantkyaw2002/Easyshell/issues                             |
| Bug Reports       | https://github.com/linthantkyaw2002/Easyshell/issues/new/choose                  |
| License           | Beta / Proprietary                                                               |
| Supported Shells  | Bash, Zsh                                                                        |
| Supported Systems | macOS, Linux, WSL                                                                |

---

## Beta Notice

Flow is currently distributed as **beta software**.

This version is intended for testing, feedback, and early usage. Some behavior, command names, storage formats, and installer logic may change in future releases.

Please report bugs, unexpected behavior, or suggestions to: linthantkyaw2002@gmail.com
---

## Package Contents

A beta release package normally includes:
```
flow-beta/
├── flow
├── install.sh
├── uninstall.sh
├── README.md
└── LICENSE
```

| File           | Purpose                                        |
|----------------|------------------------------------------------|
| `flow`         | Main Flow executable.                          |
| `install.sh`   | Installs Flow and configures the shell hook.   |
| `uninstall.sh` | Removes Flow and cleans installed files/hooks. |
| `README.md`    | User guide and command documentation.          |
| `LICENSE`      | Beta license and usage terms.                  |

---

## Table of Contents

- [Requirements](#requirements)
- [Installation](#installation)
- [Uninstallation](#uninstallation)
- [Quick Start](#quick-start)
- [Core Concepts](#core-concepts)
- [Command Summary](#command-summary)
- [Full Command Reference](#full-command-reference)
- [Storage Locations](#storage-locations)
- [Safety Notes](#safety-notes)
- [Troubleshooting](#troubleshooting)
- [Feedback](#feedback)
- [License](#license)

---

## Requirements

Flow is designed for Unix-like terminal environments.

Recommended environment:
- macOS, Linux, or WSL
- Bash or Zsh
- Standard Unix tools:
  - `chmod`
  - `cp`
  - `rm`
  - `mkdir`
  - `trap`
  - `exec`

If you are using a source-code version instead of a prebuilt beta binary, you may also need:

- `make`
- `cc`, `gcc`, or `clang`

On Ubuntu/WSL, build tools can be installed with:

```bash
sudo apt update
sudo apt install build-essential
```
---

## Installation

### 1. Extract the beta package

If you downloaded a `.zip` file:

```bash
unzip flow-beta.zip
cd flow-beta
```

If you downloaded a `.tar.gz` file:

```bash
tar -xzf flow-beta.tar.gz
cd flow-beta
```

---

### 2. Give the installer execute permission

```bash
chmod +x install.sh
```

---

### 3. Run the installer

```bash
./install.sh
```

Depending on your system permissions, the installer may ask for your password when copying Flow into `/usr/local/bin`.

---

### 4. Refresh your shell

For Bash:

```bash
exec bash
```

For Zsh:

```bash
exec zsh
```

---

### 5. Verify installation

```bash
flow list
```

Expected output when no commands are recorded yet: 
```
📝 Current Flow Workspace [0] is empty.
```

---

## Uninstallation

### 1. Give the uninstaller execute permission

```bash
chmod +x uninstall.sh
```

### 2. Run the uninstaller

```bash
./uninstall.sh
```

### 3. Refresh your shell

For Bash:

```bash
exec bash
```

For Zsh:

```bash
exec zsh
```

If your current Bash session still has old Flow hooks active, run:

```bash
trap - DEBUG
unset PROMPT_COMMAND
exec bash
```

---

## Quick Start

Start recording:

```bash
flow start
```

Run normal shell commands:

```bash
echo hello
ls
pwd
```

Stop recording:

```bash
flow stop
```

View the recorded workspace:

```bash
flow list
```

Run the current workspace:

```bash
flow run
```

Save the current workspace as a named build:

```bash
flow build demo
```

Run the saved build:

```bash
flow run demo
```

---

## Core Concepts

### Current Workspace

The current workspace is the temporary command list Flow is currently building.

Example:

```bash
flow list
```

Output:
```
📝 Current Flow Workspace [0]:
[0] make
[1] ./program
```

The workspace can be replayed directly with:

```bash
flow run
```

---

### Named Build

A named build is a saved workflow.

Example:

```bash
flow build test
```

This saves the current workspace as a reusable build named `test`.

You can run it later:

```bash
flow run test
```

---

### Recorded Directory

When a workflow is recorded, Flow stores the directory where recording started.

By default, saved builds run from their recorded directory. This is useful when commands depend on project-relative paths.

To force Flow to run from the current terminal directory, use the `-l` flag:

```bash
flow run test -l
```

---

### Index

Flow uses zero-based indexes for command steps.

Example:
```
[0] make
[1] ./program
[2] echo done
```
Valid indexes: 0, 1, 2

Some commands also support:

```bash
last
```

---

### Index Lists

Some commands accept multiple indexes separated by commas.

Example:

```bash
flow delist 0,2
```

This targets step `0` and step `2`.

Do not add spaces inside comma-separated index lists.

Correct:

```bash
flow delist 0,2
```

Incorrect:

```bash
flow delist 0, 2
```

---

## Command Summary


| Command                                        | Description                                                |
|------------------------------------------------|------------------------------------------------------------|
| `flow start`                                   | Start recording shell commands into the current workspace. |
| `flow stop`                                    | Stop the active recording session.                         |
| `flow list`                                    | Show the current workspace.                                |
| `flow list build`                              | Show saved named builds.                                   |
| `flow list <buildname>`                        | Show commands inside a saved build.                        |
| `flow list bin`                                | Show removed builds in the recovery bin.                   |
| `flow build <buildname>`                       | Save the current workspace as a named build.               |
| `flow run`                                     | Run the current workspace completely.                      |
| `flow run -l`                                  | Run the current workspace from the current directory.      |
| `flow run <index/indices>`                     | Run selected workspace steps.                              |
| `flow run <index/indices> -l`                  | Run selected workspace steps locally.                      |
| `flow run <buildname>`                         | Run a saved build completely.                              |
| `flow run <buildname> -l`                      | Run a saved build locally.                                 |
| `flow run <buildname> <index/indices>`         | Run selected steps from a saved build.                     |
| `flow run <buildname> <index/indices> -l`      | Run selected saved-build steps locally.                    |
| `flow append "<cmd>"`                          | Append a command to the current workspace.                 |
| `flow append <buildname> "<cmd>"`              | Append a command to a saved build.                         |
| `flow insert <index> "<cmd>"`                  | Insert a command into the current workspace.               |
| `flow insert <buildname> <index> "<cmd>"`      | Insert a command into a saved build.                       |
| `flow delist <index/indices/last>`             | Remove command steps from the current workspace.           |
| `flow delist <buildname> <index/indices/last>` | Remove command steps from a saved build.                   |
| `flow remove <buildname>`                      | Move a saved build to the recovery bin.                    |
| `flow remove all`                              | Move all saved builds to the recovery bin.                 |
| `flow bin restore <index/indices/last>`        | Restore removed builds from the recovery bin.              |
| `flow bin remove <index/indices/last>`         | Permanently delete selected builds from the bin.           |
| `flow bin clear`                               | Permanently clear the recovery bin.                        |
| `flow join <build1> <build2> <new_build>`      | Combine two saved builds into a new build.                 |
| `flow copy <old_build> <new_build>`            | Copy a saved build into a new build.                       |

---
For further Usage with example: https://github.com/linthantkyaw2002/Easyshell/blob/main/flow/Releases/Beta/USAGE.md 
## Full Command Reference

### `flow start`

Start a workflow recording session.

```bash
flow start
```

Example:

```bash
flow start
make
./program
flow stop
```

After this, the current workspace contains:
```
[0] make
[1] ./program
```
Notes:

- Flow commands are ignored during recording to prevent recursive workflows.
- If recording is already active, Flow prints a warning.

---

### `flow stop`

Stop the active workflow recording session.

```bash
flow stop
```

If no recording session is active, Flow prints a warning.

---

### `flow list`

Show the current workspace.

```bash
flow list
```

Example output:
```
📝 Current Flow Workspace [0]:
[0] echo hello
[1] ls
```

---

### `flow list build`

Show all saved named builds.

```bash
flow list build
```

Example output:
```
📦 Saved Macro Builds:
[•] test
[•] demo
```

---

### `flow list <buildname>`

Show commands inside a saved build.

```bash
flow list test
```

Example output:
```
📋 Saved Build 'test':
[0] make
[1] ./program
```
---

### `flow list bin`

Show builds currently stored in the recovery bin.

```bash
flow list bin
```

Example output:
```
♻️ Archived Garbage Tracks in Recycling Bin (newest first):
[0] old_build
[1] demo_backup
```

Use this before restoring or permanently deleting removed builds.

---

### `flow build <buildname>`

Save the current workspace as a named build.

```bash
flow build test
```

If a build with the same name already exists, Flow asks for confirmation before overwriting it.

Example:

⚠️ Saved build 'test' already exists. Overwrite it? [y/N]

Flow also prevents empty workspaces from being saved as builds.

---

### `flow run`

Run the current workspace completely.

```bash
flow run
```

Example output:

🚀 Running current flow workspace [0] completely...
```
Flow▶️ [0]: make
Flow▶️ [1]: ./program
```
---

### `flow run -l`

Run the current workspace from the current terminal directory.

```bash
flow run -l
```

Use this when you want to ignore the recorded directory.

---

### `flow run <index/indices>`

Run selected steps from the current workspace.

```bash
flow run 0
```

Run multiple selected steps:

```bash
flow run 0,2
```

---

### `flow run <index/indices> -l`

Run selected workspace steps locally.

```bash
flow run 0,2 -l
```

---

### `flow run <buildname>`

Run a saved named build completely.

```bash
flow run test
```

By default, Flow uses the saved build's recorded directory metadata if available.

---

### `flow run <buildname> -l`

Run a saved build from the current terminal directory.

```bash
flow run test -l
```

---

### `flow run <buildname> <index/indices>`

Run selected steps from a saved build.

```bash
flow run test 0
```

Run multiple selected steps:

```bash
flow run test 0,2
```

---

### `flow run <buildname> <index/indices> -l`

Run selected steps from a saved build locally.

```bash
flow run test 0,2 -l
```

---

### `flow append "<cmd>"`

Append a command to the current workspace.

```bash
flow append "echo hello"
```

Use quotes when the command contains spaces.

---

### `flow append <buildname> "<cmd>"`

Append a command to a saved build.

```bash
flow append test "echo done"
```

---

### `flow insert <index> "<cmd>"`

Insert a command into the current workspace at a specific index.

```bash
flow insert 1 "echo inserted"
```

Example before:
```
[0] make
[1] ./program
```

After:
```
[0] make
[1] echo inserted
[2] ./program
```
---

### `flow insert <buildname> <index> "<cmd>"`

Insert a command into a saved build.

```bash
flow insert test 1 "echo inserted"
```

---

### `flow delist <index/indices/last>`

Remove one or more commands from the current workspace.

Remove one step:

```bash
flow delist 0
```

Remove multiple steps:

```bash
flow delist 0,2
```

Remove the last step:

```bash
flow delist last
```

After deletion, Flow re-indexes the remaining commands.

Invalid values such as `abc`, `1abc`, `0,,1`, or `1,` are rejected.

---

### `flow delist <buildname> <index/indices/last>`

Remove one or more commands from a saved build.

```bash
flow delist test 1
```

Remove multiple steps:

```bash
flow delist test 0,2
```

Remove the last step:

```bash
flow delist test last
```

---

### `flow remove <buildname>`

Move a saved build to the recovery bin.

```bash
flow remove test
```

This does not permanently delete the build. It moves the build into Flow's recovery bin.

---

### `flow remove all`

Move all saved builds to the recovery bin.

```bash
flow remove all
```

Use this carefully. Builds can be recovered unless the bin is cleared.

---

### `flow bin restore <index/indices/last>`

Restore removed builds from the recovery bin.

First list the bin:

```bash
flow list bin
```

Restore one item:

```bash
flow bin restore 0
```

Restore multiple items:

```bash
flow bin restore 0,1
```

Restore the most recently deleted item:

```bash
flow bin restore last
```

---

### `flow bin remove <index/indices/last>`

Permanently remove selected builds from the recovery bin.

First list the bin:

```bash
flow list bin
```

Remove one item:

```bash
flow bin remove 0
```

Remove multiple items:

```bash
flow bin remove 0,1
```

Remove the most recently deleted item:

```bash
flow bin remove last
```

Warning: this action is permanent.

---

### `flow bin clear`

Permanently clear all items from the recovery bin.

```bash
flow bin clear
```

Warning: this permanently deletes all removed builds stored in the bin.

---

### `flow join <build1> <build2> <new_build>`

Join two saved builds into a new saved build.

```bash
flow join setup test full_test
```

This creates a new build named `full_test` that contains commands from `setup` followed by commands from `test`.

If the destination build already exists, Flow asks for confirmation before overwriting it.

---

### `flow copy <old_build> <new_build>`

Copy a saved build into another saved build.

```bash
flow copy test test_backup
```

This creates a new build named `test_backup` with the same command list as `test`.

If the destination build already exists, Flow asks for confirmation before overwriting it.

---

## Storage Locations

Flow uses local files and directories on your machine.


| Path                              | Purpose                                            |
|-----------------------------------|----------------------------------------------------|
| `/usr/local/bin/flow`             | Installed Flow executable.                         |
| `~/.flow_macros/`                 | Saved named builds.                                |
| `~/.flow_macros/.bin/`            | Recovery bin for removed builds.                   |
| `/tmp/.flow_record_cache`         | Current workspace cache.                           |
| `/tmp/.flow_active_state`         | Recording state flag.                              |
| `/tmp/.flow_recorded_path`        | Directory where recording started.                 |
| `/tmp/.flow_execution_wrapper.sh` | Temporary replay script created during `flow run`. |

---

## Safety Notes

- Commands with spaces should be quoted when using `append` or `insert`.
- Flow blocks recording of Flow commands to avoid recursive workflows.
- `flow remove <buildname>` moves builds to the recovery bin instead of deleting them immediately.
- `flow bin remove` and `flow bin clear` permanently delete builds from the recovery bin.
- Use `flow list`, `flow list build`, and `flow list bin` before deleting or restoring items.
- Review recorded commands before running workflows that affect files, databases, or system configuration.

---

## Troubleshooting

### `flow: command not found`

Refresh your shell:

```bash
exec bash
```

Or for Zsh:

```bash
exec zsh
```

Check that Flow was installed:

```bash
ls -l /usr/local/bin/flow
```

---

### `Permission denied` when running the installer

Give the installer execute permission:

```bash
chmod +x install.sh
```

Then run it again:

```bash
./install.sh
```

---

### `Permission denied` when installing to `/usr/local/bin`

Run the installer normally first:

```bash
./install.sh
```

If permission is required, enter your password when prompted.

You can also manually copy the binary:

```bash
sudo cp flow /usr/local/bin/flow
sudo chmod +x /usr/local/bin/flow
```

---

### Old Flow hook still active

Run:

```bash
trap - DEBUG
unset PROMPT_COMMAND
exec bash
```

Then reinstall Flow:

```bash
./install.sh
exec bash
```

---

### `ls` records as `ls --color=auto`

This can happen when shell aliases are expanded by the shell hook.

Check your alias:

```bash
ls
```

If needed, reinstall Flow and restart Bash:

```bash
./install.sh
trap - DEBUG
exec bash
```

---

### Repeated commands record only once

Example:

```bash
echo hi
echo hi
```

If only one command is saved, your shell hook may be using shell history behavior instead of direct command tracing, or duplicate-history settings may be interfering.

Reinstall Flow using the latest installer, then refresh your shell:

```bash
./install.sh
trap - DEBUG
exec bash
```

---

## Feedback

Flow is in beta, and feedback is welcome.

Please report bugs, unexpected behavior, or suggestions through GitHub Issues:

- Bug reports or Feature requests: https://github.com/linthantkyaw2002/Easyshell/issues/new/choose
- For discusoins: https://github.com/linthantkyaw2002/Easyshell/discussions

For private or security-related contact, email: linthantkyaw2002@gmail.com

GitHub profile: https://github.com/linthantkyaw2002

When reporting a bug, please include:

- Operating system, for example Ubuntu, Debian, macOS, or WSL
- Terminal app, for example Windows Terminal, GNOME Terminal, iTerm2, or VS Code terminal
- Shell type, for example Bash or Zsh
- EasyShell / Flow version
- Installation method
- Command used
- Expected behavior
- Actual behavior
- Terminal output or error message

---

## License

Flow CLI Tool is currently distributed as beta/proprietary software.

Copyright (c) 2026 Lin Thant Kyaw.
All rights reserved.

You may install and test this beta version, but you may not copy, modify, redistribute, sell, repackage, reverse engineer, or use it commercially without written permission from the author.

See the `LICENSE` file for full terms.

---

## Author

**Lin Thant Kyaw**

- Private contact: `linthantkyaw2002@gmail.com`
- GitHub: `https://github.com/linthantkyaw2002`
