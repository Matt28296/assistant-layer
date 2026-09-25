# Changelog

Changes to this template. A copy made with "Use this template" does not receive them by itself.
Compare the dates here with the setup date in the `IDENTITY.md` of your head repository.

## Unreleased

### Fixed

- `tools/fill-placeholders.ps1` (shared with `head-orchestrator`):
  - Running it again after an OK fill no longer prints OK. A corrected value was never applied on a
    re-run, because no placeholders were left to fill. It now stops with `NOT DONE - nothing to fill`
    (exit 3) and says how to put the templates back.
  - It fills every file in memory and writes nothing unless the result is complete. Before, a run that
    left a placeholder had already written the files it could fill.
  - Reads the values file as UTF-8. Windows PowerShell 5.1 read a values file saved without a
    byte-order mark in the ANSI code page, which garbled accented names in every filled file.
  - Fills files inside dot-folders. pwsh on macOS and Linux skipped them as hidden.
  - Checks the machine values before writing: `HOSTNAME` must be what `hostname` prints,
    `ASSISTANT_DIR` and `HEAD_DIR` must be two folders directly inside `AGENTS_ROOT`, and the
    repository must be one of them (exit 2).
- `SETUP.md` step 8 and `state/AGENT-REGISTRY.md`: after the round-trip test both seats are marked
  `ATTENDED`, not `VERIFIED-ACTIVE`. Both are attended sessions with no declared cadence, and the
  status table requires a cadence for `VERIFIED-ACTIVE`.
- `SETUP.md` step 9: the operator no longer commits the head repository while the seats run there;
  the seats commit their own paths.
- `CLAUDE.md` section 2 and `SETUP.md` step 11: a brief is posted to the bus with its full path, which
  the head can open, not only its file name.

### Added

- `SETUP.md`:
  - step 2: set git's user name and email before the first commit;
  - step 5: what the filler checks, and how to recover from a wrong value after an OK fill;
  - step 7: commit the filled templates once before either seat starts, and the trust-folder and
    permission prompts Claude Code shows on first launch;
  - a note that the Mac path has not yet been run end to end.
- `CLAUDE.md` section 7: the exact commit command for the assistant's two bus paths.
- `tests/test-fill-placeholders.ps1` (shared): offline checks for the filler, placeholder coverage of
  the templates, and the files shared with `head-orchestrator`. It needs no modules.
- `.github/workflows/template-checks.yml`: runs those checks on Windows PowerShell 5.1, and on
  PowerShell 7 on Windows and macOS, in this public template only.
- `examples/`: a fictional filled install.
- `.gitattributes`: the `.sh` launchers keep LF line endings and the `.cmd` launchers keep CRLF.
- `README.md`: a diagram of the two seats, a link to the companion repository, and the background
  sections from the first publication.
- `docs/brains/LIBRARIAN.md` (shared): states that the librarian is a pattern only in this template.

## 2026-09-12

- Converted from reference documents to a deployable template (`05b5720`).
- First published as reference documents (`b4c0c1f`).
