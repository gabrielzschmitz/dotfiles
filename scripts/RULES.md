# Shell Script Documentation and Formatting Rules

This file is authoritative for every script in `scripts/`. Apply these rules to
new scripts and when editing existing scripts. Preserve behavior unless a
change is required to meet a rule or fix a defect.

## Script Documentation

- Keep a valid interpreter line as the first line.
- Start with a short summary of what the script does.
- Document external dependencies and their purpose when useful.
- Document selection rules, actions, defaults, state files, and configuration
  that affect how the script behaves.
- Include usage and supported options when the script accepts arguments.
- Put a short comment immediately before every function. Explain its purpose,
  inputs, outputs, and important side effects where these are not obvious.
- Document important control-flow decisions and non-obvious behavior.
- Explain why code exists; do not repeat what command syntax already says.
- Keep comments concise, accurate, and consistent with current behavior.
- Prefer parameterized functions with clear responsibilities. Avoid hidden
  dependencies on mutable global variables where practical.
- Keep existing behavior and avoid unnecessary abstractions or refactoring.

## Functions and Main Pattern

- Organize scripts with functions when doing so improves readability,
  separation of responsibilities, or argument handling.
- Use a `main()` function as the script's entry point when the script has
  multiple operations or functions.
- Call `main "$@"` at the end of the script.
- Keep top-level code limited to declarations, function definitions, and the
  final `main` invocation. Avoid executing the main workflow directly at the
  top level.
- Define functions before `main()` when practical.

### Recommended Function Structure

- `usage()`: Print the supported invocation syntax and, when useful, a brief
  description of arguments. Send usage information to stderr when reporting
  invalid arguments.
- `parse_args()`: Parse command-line arguments, validate required values,
  reject unsupported options, and establish the selected configuration.
  Preserve argument boundaries through proper quoting.
- Action functions: Implement individual responsibilities, such as opening
  files, downloading resources, processing data, or managing services.
- `main()`: Coordinate argument parsing, initialization, and action functions.
  Keep it concise and make the execution flow explicit.

### Function Conventions

- Use descriptive function names in lowercase with underscores when needed.
- Prefer passing arguments explicitly rather than relying on positional
  parameters or mutable global variables from the surrounding script.
- Use `local` only when targeting shells that support it; it is not POSIX. For
  POSIX `sh`, use clearly named variables and document unavoidable
  function-scoped state when necessary.
- Use `return` for function status and reserve `exit` for terminating the
  script. Argument parsers may terminate the script directly when invalid input
  makes further execution impossible.
- Use `exec` when the script should replace itself with the final command,
  avoiding an unnecessary parent shell process.
- Preserve and propagate command exit statuses. Do not accidentally replace an
  important status with the result of a subsequent command.
- Do not introduce functions solely to wrap trivial commands when doing so
  makes the script harder to understand.

### Example Structure

```sh
#!/bin/sh

# Brief description of the script.

# Print supported invocation syntax.
usage() {
  printf 'Usage: script [OPTIONS] [ARGUMENT]\n' >&2
}

# Parse arguments and establish the selected configuration.
parse_args() {
  # Argument parsing.
  :
}

# Perform the primary operation.
perform_action() {
  # Main operation.
  :
}

# Coordinate initialization and execution.
main() {
  parse_args "$@"
  perform_action
}

main "$@"
```

## Shell Style

- Use POSIX `sh` unless a script requires Bash features. Use Bash explicitly
  when Bash-specific syntax is necessary.
- Quote variable expansions unless word splitting or globbing is intentional.
- Use descriptive variable names and consistent terminology.
- Keep every physical script line within 80 columns.
- Do not break words to satisfy the line limit. Rephrase comments or code; keep
  an indivisible token whole when splitting it would change its meaning.
- Preserve executable permissions for executable scripts.

## Formatting

- Format every shell script with `shfmt`.
- Use two-space indentation and these formatter options: `-i 2 -ci -bn -sr`.
- Run formatter with: `shfmt -i 2 -ci -bn -sr -w scripts/&lt;script&gt;`
- Check formatting with: `shfmt -i 2 -ci -bn -sr -d scripts/&lt;script&gt;`
- `shfmt` does not wrap long lines. Wrap comments separately, preserving
  indentation and the comment prefix on every wrapped line.
- Wrap comments at 80 columns. Do not split words. If one unbreakable token
  alone exceeds the limit, keep it whole and document why if needed.
- Keep formatting consistent across scripts. Make exceptions only when a shell
  or tool constraint technically requires one, and document the reason.

## Editor and Language Server

- Configure `bashls` for both `sh` and `bash` filetypes.
- Use `shfmt` as the dedicated formatter for both filetypes.
- Pass `-i 2 -ci -bn -sr` to `shfmt` from editor formatting.
- Format scripts automatically on save.
- Enable comment and prose wrapping at 80 columns. Preserve indentation and
  comment prefixes, and never split words while wrapping comments.
- Use LSP formatting as fallback when no dedicated formatter is available.
- Keep editor behavior aligned with these rules; do not add script-specific
  formatting exceptions without technical need.

## Verification

- Run `shfmt -i 2 -ci -bn -sr -d` on every shell script after editing.
- Run `sh -n` on POSIX shell scripts. Run `bash -n` on Bash-only scripts.
- Check that comments wrap at 80 columns and retain their prefixes.
- Test affected argument handling, exit statuses, and side effects when
  practical. Do not run destructive actions as tests.
