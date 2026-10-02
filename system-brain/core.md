# CORE — how this system works

**One page. Loads every session.** **No live numbers on this page** — current figures belong in state
files with a time of measurement.

## Chain of command

{{PRINCIPAL_NAME}} → **assistant** (`{{ASSISTANT_DIR}}`) → **head** (`{{HEAD_DIR}}`) → **division orchestrators** → **workers**.

- The assistant clarifies, organises and writes briefs.
- The Head delegates to division orchestrators, accepts verified results, and keeps delivery moving.
- Division orchestrators direct workers; workers produce and verify deliverables.
- Neither top seat performs production work. See `docs/NETWORK-CONTRACT.md`.
- **{{OPERATOR_NAME}}** supports the setup and is not in the chain of authority.

## Seats

`{{ASSISTANT_BUS_DIR}}/IDENTITY.md` is the authority. Do not copy the table here.

## Bus

`{{ASSISTANT_BUS_DIR}}` — your exclusive checkout of the selected coordination remote — `msg/<seat>.md` (append-only) + `state/<seat>.json` (overwrite).
**Read state files for summaries; logs are archives.** Commit your own paths every turn.

## Hard lines

Money · identity · sending to clients or the public · deleting · client private documents ·
a safety refusal. Details: `CLAUDE.md` §6.

## Tools this business uses

| Tool | Used for | Connected by | Notes |
|---|---|---|---|
| _CRM_ | | {{PRINCIPAL_NAME}} (sign-in) | |
| _email_ | | {{PRINCIPAL_NAME}} (sign-in) | |
| _file storage_ | | {{PRINCIPAL_NAME}} (sign-in) | |
| _team chat_ | | {{PRINCIPAL_NAME}} (sign-in) | |

## The work, stage by stage

_Fill from discovery. One line per stage: who does it, what finishes it, what gets sent, what the
reminder rule is._

## Where to look

- `docs/LAWS.md` — failure modes to avoid
- `docs/AUTHORITY.md` — levels and hard lines
- `system-brain/MAP.md` — every note in this vault
