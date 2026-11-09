# Shell Script Documentation and Formatting Rules

This file is authoritative for every script in `scripts/`. Apply these rules
to new scripts and when editing existing scripts. Preserve behavior unless a
change is required to meet a rule or fix a defect.

## Script Documentation

- Keep a valid interpreter line as the first line.
- Start with a short summary of what script does.
- Document external dependencies and their purpose when useful.
- Document selection rules, actions, defaults, state files, and configuration
  that affect how script behaves.
- Include usage and supported options when script accepts arguments.
- Put a short comment immediately before every function. Explain its purpose,
  inputs, outputs, and important side effects where these are not obvious.
- Document important control-flow decisions and non-obvious behavior.
- Explain why code exists; do not repeat what command syntax already says.
- Keep comments concise, accurate, and consistent with current behavior.
- Prefer parameterized functions with clear responsibilities. Avoid hidden
  dependencies on mutable global variables where practical.
- Keep existing behavior and avoid unnecessary abstractions or refactoring.

## Shell Style

- Use POSIX `sh` unless a script requires Bash features. Use Bash explicitly
  when Bash-specific syntax is necessary.
- Quote variable expansions unless word splitting or globbing is intentional.
- Use descriptive names and consistent terminology for the same concept.
- Keep every physical script line within 80 columns.
- Do not break words to satisfy the line limit. Rephrase comments or code;
  keep an indivisible token whole when splitting it would change its meaning.
- Preserve executable permissions for executable scripts.

## Formatting

- Format every shell script with `shfmt`.
- Use two-space indentation and these formatter options:
  `-i 2 -ci -bn -sr`.
- Run formatter with:
  `shfmt -i 2 -ci -bn -sr -w scripts/<script>`
- Check formatting with:
  `shfmt -i 2 -ci -bn -sr -d scripts/<script>`
- `shfmt` does not wrap long lines. Wrap comments separately, preserving
  indentation and the comment prefix on every wrapped line.
- Wrap comments at 80 columns. Do not split words. If one unbreakable token
  alone exceeds the limit, keep it whole and document why if needed.
- Keep formatting consistent across scripts. Make exceptions only when a
  shell or tool constraint technically requires one, and document the reason.

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
