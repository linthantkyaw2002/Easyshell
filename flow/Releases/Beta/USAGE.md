# EasyShell / Flow Usage Guide

This guide explains how to use **EasyShell / Flow** with beginner-friendly examples.

EasyShell / Flow is a terminal workflow recorder. It lets you record commands once, save them as a named workflow, and run them again later.

For example, instead of typing this every time:

```bash
make fclean
make
./program
```

you can record it once and run it later with:

```bash
flow run build-test
```

---

## Table of Contents

- [Basic Idea](#basic-idea)
- [Important Terms](#important-terms)
- [Quick Start](#quick-start)
- [Command Summary](#command-summary)
- [Beginner Examples](#beginner-examples)
  - [Example 1: Record and replay simple commands](#example-1-record-and-replay-simple-commands)
  - [Example 2: Save a build workflow](#example-2-save-a-build-workflow)
  - [Example 3: Create a web project file structure](#example-3-create-a-web-project-file-structure)
  - [Example 4: Create a C project file structure](#example-4-create-a-c-project-file-structure)
  - [Example 5: Save a Git workflow](#example-5-save-a-git-workflow)
  - [Example 6: Edit a saved workflow](#example-6-edit-a-saved-workflow)
  - [Example 7: Run only selected steps](#example-7-run-only-selected-steps)
  - [Example 8: Remove and restore saved builds](#example-8-remove-and-restore-saved-builds)
  - [Example 9: Run tester files from different directories](#example-9-run-tester-files-from-different-directories)
- [Local Run Mode](#local-run-mode)
- [Safety Tips](#safety-tips)
- [Common Beginner Mistakes](#common-beginner-mistakes)
- [Recommended Beginner Workflows](#recommended-beginner-workflows)
- [Getting Help](#getting-help)

---

## Basic Idea

EasyShell / Flow works like this:

1. Start recording.
2. Run normal terminal commands.
3. Stop recording.
4. Save the recorded commands as a named build.
5. Run the saved build anytime.

Basic pattern:

```bash
flow start

# Run your normal commands here

flow stop
flow list
flow build my-workflow
flow run my-workflow
```

---

## Important Terms

### Current workspace

The **current workspace** is the temporary list of commands you just recorded.

You can see it with:

```bash
flow list
```

You can run it with:

```bash
flow run
```

---

### Named build

A **named build** is a saved workflow.

Example:

```bash
flow build test
```

After saving, you can run it anytime:

```bash
flow run test
```

---

### Recovery bin

When you remove a saved build, it is moved to the recovery bin first.

Example:

```bash
flow remove test
```

You can view removed builds:

```bash
flow list bin
```

You can restore one:

```bash
flow bin restore 0
```

---

## Quick Start

Start recording:

```bash
flow start
```

Run normal commands:

```bash
echo "Hello from Flow"
pwd
ls
```

Stop recording:

```bash
flow stop
```

View recorded commands:

```bash
flow list
```

Run the recorded commands:

```bash
flow run
```

Save the recorded commands:

```bash
flow build hello
```

Run the saved build:

```bash
flow run hello
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
| `flow append "<cmd>"`                         | Append a command to the current workspace.                 |
| `flow append <buildname> "<cmd>"`             | Append a command to a saved build.                         |
| `flow insert <index> "<cmd>"`                 | Insert a command into the current workspace.               |
| `flow insert <buildname> <index> "<cmd>"`     | Insert a command into a saved build.                       |
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

# Beginner Examples

## Example 1: Record and replay simple commands

This example records a few simple commands.

```bash
flow start
echo "Hello"
pwd
ls
flow stop
```

View what was recorded:

```bash
flow list
```

Example output:

```text
[0] echo "Hello"
[1] pwd
[2] ls
```

Run the recorded workspace:

```bash
flow run
```

Save it:

```bash
flow build simple-demo
```

Run it later:

```bash
flow run simple-demo
```

---

## Example 2: Save a build workflow

This is useful for compiled projects.

Example project workflow:

```bash
make fclean
make
./program
```

Record it:

```bash
flow start
make fclean
make
./program
flow stop
```

Check the recorded commands:

```bash
flow list
```

Save the workflow:

```bash
flow build build-test
```

Run it later:

```bash
flow run build-test
```

This is useful when you repeatedly compile and run the same project.

---

## Example 3: Create a web project file structure

This example creates a simple web project structure:

```text
my-website/
├── index.html
├── css/
│   └── style.css
├── js/
│   └── app.js
├── images/
└── README.md
```

First, create a temporary folder where you will record the template:

```bash
mkdir flow-template-recording
cd flow-template-recording
```

Start recording:

```bash
flow start
```

Run these commands:

```bash
mkdir -p css js images
touch index.html css/style.css js/app.js README.md
printf '<!DOCTYPE html>\n<html>\n<head>\n  <title>My Website</title>\n  <link rel="stylesheet" href="css/style.css">\n</head>\n<body>\n  <h1>Hello, EasyShell / Flow!</h1>\n  <script src="js/app.js"></script>\n</body>\n</html>\n' > index.html
printf 'body {\n  font-family: Arial, sans-serif;\n  margin: 40px;\n}\n' > css/style.css
printf 'console.log("Hello from EasyShell / Flow");\n' > js/app.js
printf '# My Website\n\nCreated with EasyShell / Flow.\n' > README.md
```

Stop recording:

```bash
flow stop
```

View the recorded commands:

```bash
flow list
```

Save it as a reusable web template:

```bash
flow build web-template
```

Now create a new website project anywhere:

```bash
cd ..
mkdir my-website
cd my-website
```

Run the saved template in the current directory:

```bash
flow run web-template -l
```

The `-l` flag is important here. It tells Flow to run the saved workflow in your current directory.

Check the result:

```bash
ls
```

You should see:

```text
README.md  css  images  index.html  js
```

---

## Example 4: Create a C project file structure

This example creates a beginner C project structure:

```text
my-c-project/
├── Makefile
├── README.md
├── include/
│   └── project.h
└── src/
    └── main.c
```

Create a temporary recording folder:

```bash
mkdir flow-c-template-recording
cd flow-c-template-recording
```

Start recording:

```bash
flow start
```

Run these commands:

```bash
mkdir -p src include
touch src/main.c include/project.h Makefile README.md
printf '#include <stdio.h>\n\nint main(void)\n{\n    printf("Hello from C project!\\n");\n    return 0;\n}\n' > src/main.c
printf '#ifndef PROJECT_H\n#define PROJECT_H\n\n#endif\n' > include/project.h
printf 'NAME = program\nCC = cc\nCFLAGS = -Wall -Wextra -Werror\nSRC = src/main.c\n\nall:\n\t$(CC) $(CFLAGS) $(SRC) -o $(NAME)\n\nclean:\n\trm -f $(NAME)\n\nfclean: clean\n\nre: fclean all\n' > Makefile
printf '# My C Project\n\nCreated with EasyShell / Flow.\n' > README.md
```

Stop recording:

```bash
flow stop
```

Save it:

```bash
flow build c-template
```

Now create a real project folder:

```bash
cd ..
mkdir my-c-project
cd my-c-project
```

Run the template locally:

```bash
flow run c-template -l
```

Build the project:

```bash
make
```

Run it:

```bash
./program
```

---

## Example 5: Save a Git workflow

You can save repeated Git commands.

Example workflow:

```bash
git status
git add .
git status
```

Record it:

```bash
flow start
git status
git add .
git status
flow stop
```

Save it:

```bash
flow build git-check
```

Run it inside any Git project:

```bash
flow run git-check -l
```

Important: Be careful when recording commands like `git commit`, `git push`, or `rm -rf`. Always check your saved workflow before running it.

---

## Example 6: Edit a saved workflow

List saved builds:

```bash
flow list build
```

Show a saved build:

```bash
flow list web-template
```

Append a new command to a saved build:

```bash
flow append web-template "touch .gitignore"
```

Insert a command at index `1`:

```bash
flow insert web-template 1 "mkdir -p assets"
```

Remove a command from the saved build:

```bash
flow delist web-template 2
```

Show the updated saved build:

```bash
flow list web-template
```

---

## Example 7: Run only selected steps

Suppose your saved build looks like this:

```text
[0] mkdir -p css js images
[1] touch index.html css/style.css js/app.js README.md
[2] printf '...' > index.html
[3] printf '...' > css/style.css
[4] printf '...' > js/app.js
```

Run only step `0`:

```bash
flow run web-template 0 -l
```

Run steps `0` and `1`:

```bash
flow run web-template 0,1 -l
```

Run the full saved build:

```bash
flow run web-template -l
```

Do not add spaces inside index lists.

Correct:

```bash
flow run web-template 0,1 -l
```

Incorrect:

```bash
flow run web-template 0, 1 -l
```

---

## Example 8: Remove and restore saved builds

List saved builds:

```bash
flow list build
```

Remove a saved build:

```bash
flow remove web-template
```

This does not permanently delete it. It moves the build to the recovery bin.

View the recovery bin:

```bash
flow list bin
```

Restore the first item in the bin:

```bash
flow bin restore 0
```

Permanently delete the first item in the bin:

```bash
flow bin remove 0
```

Clear the entire bin:

```bash
flow bin clear
```

Warning: `flow bin remove` and `flow bin clear` are permanent.

---

## Local Run Mode

By default, Flow may run a saved build from the directory where it was recorded.

For reusable templates, use `-l`.

Example:

```bash
flow run web-template -l
```

This means:

> Run `web-template` in the current terminal directory.

Use `-l` when your workflow should run inside the folder you are currently in.

Good examples for `-l`:

```bash
flow run web-template -l
flow run c-template -l
flow run git-check -l
```

---

## Example 9: Run tester files from different directories

This example is useful when your project has several tester files in different folders.

Example project structure:

```text
my-project/
├── Makefile
├── program
├── src/
├── tests/
│   ├── basic/
│   │   └── test_basic.sh
│   ├── parser/
│   │   └── test_parser.sh
│   ├── memory/
│   │   └── test_memory.sh
│   └── bonus/
│       └── test_bonus.sh
```

Instead of manually running every tester file one by one:

```bash
make re
bash tests/basic/test_basic.sh
bash tests/parser/test_parser.sh
bash tests/memory/test_memory.sh
bash tests/bonus/test_bonus.sh
```

you can save the whole testing workflow with EasyShell / Flow.

Go to your project root:

```bash
cd my-project
```

Start recording:

```bash
flow start
```

Run your build and tester commands:

```bash
make re
bash tests/basic/test_basic.sh
bash tests/parser/test_parser.sh
bash tests/memory/test_memory.sh
bash tests/bonus/test_bonus.sh
```

Stop recording:

```bash
flow stop
```

Check what was recorded:

```bash
flow list
```

Save the workflow:

```bash
flow build run-testers
```

Now you can run all testers anytime:

```bash
flow run run-testers
```

If you are inside another copy of the same project structure, run it locally:

```bash
flow run run-testers -l
```

The `-l` flag tells Flow to run the saved workflow from your current directory.

---

### Running only one tester

If your saved build looks like this:

```text
[0] make re
[1] bash tests/basic/test_basic.sh
[2] bash tests/parser/test_parser.sh
[3] bash tests/memory/test_memory.sh
[4] bash tests/bonus/test_bonus.sh
```

Run only the basic tester:

```bash
flow run run-testers 1 -l
```

Run only parser and memory testers:

```bash
flow run run-testers 2,3 -l
```

Run the full tester workflow:

```bash
flow run run-testers -l
```

Do not add spaces in index lists.

Correct:

```bash
flow run run-testers 2,3 -l
```

Incorrect:

```bash
flow run run-testers 2, 3 -l
```

---

### Running external testers from outside the project

Sometimes tester folders are outside your project.

Example structure:

```text
workspace/
├── my-project/
│   ├── Makefile
│   └── program
├── basic-tester/
│   └── run.sh
├── parser-tester/
│   └── run.sh
└── memory-tester/
    └── run.sh
```

From inside your project:

```bash
cd workspace/my-project
```

Start recording:

```bash
flow start
```

Run the external testers:

```bash
make re
sh -c 'PROJECT_DIR="$(pwd)"; cd ../basic-tester && ./run.sh "$PROJECT_DIR/program"'
sh -c 'PROJECT_DIR="$(pwd)"; cd ../parser-tester && ./run.sh "$PROJECT_DIR/program"'
sh -c 'PROJECT_DIR="$(pwd)"; cd ../memory-tester && ./run.sh "$PROJECT_DIR/program"'
```

Stop recording:

```bash
flow stop
```

Save it:

```bash
flow build external-testers
```

Run it again from the same project:

```bash
flow run external-testers
```

Run it from another project with the same folder layout:

```bash
flow run external-testers -l
```

This is useful when you keep tester tools in separate directories next to your project.

---

### Recommended tester workflows

You can save different tester workflows for different purposes:

```bash
flow build test-basic
flow build test-parser
flow build test-memory
flow build test-bonus
flow build test-all
```

Example usage:

```bash
flow run test-basic -l
flow run test-memory -l
flow run test-all -l
```

For testing workflows, using `-l` is usually recommended because you often want to run the testers in the project folder you are currently working in.
## Safety Tips

Before running a saved build, check it:

```bash
flow list <buildname>
```

Example:

```bash
flow list web-template
```

Be careful with commands that:

- Delete files
- Move files
- Overwrite files
- Push code to GitHub
- Change system settings
- Use `sudo`

Dangerous examples:

```bash
rm -rf *
sudo rm -rf /some/path
git push --force
```

If you are not sure what a saved build does, list it before running it.

---

## Common Beginner Mistakes

### Forgetting to stop recording

If you start recording, remember to stop:

```bash
flow stop
```

---

### Forgetting to save the workflow

Recording creates a temporary workspace. To reuse it later, save it:

```bash
flow build my-workflow
```

---

### Running a template without `-l`

For templates, use:

```bash
flow run template-name -l
```

Without `-l`, Flow may run from the original recorded directory.

---

### Using spaces in index lists

Correct:

```bash
flow run test 0,2
```

Incorrect:

```bash
flow run test 0, 2
```

---

### Not checking a build before running it

Always check important workflows first:

```bash
flow list build-name
```

---

## Recommended Beginner Workflows

Good workflows to save:

```bash
flow build web-template
flow build c-template
flow build build-test
flow build git-check
```

Example usage:

```bash
flow run web-template -l
flow run c-template -l
flow run build-test
flow run git-check -l
```

---

## Getting Help

Check the main README for installation, troubleshooting, license, and project information.

For bugs or feature requests, open a GitHub issue:

```text
https://github.com/linthantkyaw2002/Easyshell/issues/new/choose
```
