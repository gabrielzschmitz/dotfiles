## Task planning

For any task with three or more steps, or three or more files, call `todowrite` once before other tools.

- One todo per step or per file. Never batch several items into one todo.
- When the task names a set of files, create one todo for every file in that set. Do not sample or summarize.
- Mark a todo `in_progress` when starting it and `completed` when done.

## Repository rules

Before editing, check the repository root for `CONTRIBUTE.md`, `CONTRIBUTING.md`, or `docs/CONTRIBUTING.md`.

If one exists, read it with the `read` tool and treat it as binding:

- It overrides generic style habits, not safety rules.
- It applies to every edited file, not only the one named.
- Run the formatter the repo declares before reporting.

If none exists, follow existing style in the touched directory without reformatting unrelated lines.

## Formatter detection

Run the formatter only when its config or file type is present:

- `.clang-format` or C/C++ sources: `clang-format -i` on the edited file
- `stylua.toml` or Lua: `stylua`
- `flake.nix` or Nix: `nixfmt`
- `biome.json` or TS/JS: `biome format --write`
- Otherwise run the command named in `CONTRIBUTE.md`

Never run a formatter that the repo does not declare.

## Toolchain

Use the repository's declared environment when it exists:

- `shell.nix` or `default.nix`: run tool commands as `nix-shell --run '<command>'`
- `flake.nix` with a devShell: `nix develop -c '<command>'`
- `devbox.json`: `devbox run -- <command>`
- `mise.toml` or `.tool-versions`: `mise exec -- <command>`

Only wrap the command that needs the tool, for example `nix-shell --run 'clang-format -i src/foo.c'`.

Rules:

- Detect the environment once per session; reuse the same form.
- Do not start an environment when the command already works on the host.
- If the shell entry fails, report it once and fall back to host tools. Never retry in a loop.
- Do not run `nix-shell` for `git`, `grep`, `read`, or other basic tools.
