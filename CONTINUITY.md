# CONTINUITY — what runs where, and what survives a restart

**Update this file in the same change whenever anything is added, moved or retired.**
The principles behind it are in `docs/CONTINUITY.md`.

## This machine: `{{HOSTNAME}}`

| Component | Class | Survives a restart? | Brings it back | Who has to be there |
|---|---|---|---|---|
| assistant seat (`{{ASSISTANT_DIR}}`) | attended session | **No** | `tools/launch-assistant.cmd` (Mac: `launch-assistant.sh`) | someone at the machine |
| head seat (`{{HEAD_DIR}}`) | attended session | **No** | `{{HEAD_DIR}}/tools/launch-head.cmd` (Mac: `launch-head.sh`) | someone at the machine |
| signed-in business apps (CRM, email, storage, chat) | interactive dependency | **No** | open each app | **{{PRINCIPAL_NAME}} — signing in is identity** |

**Add a row for every scheduled job, integration or service the moment it exists.**

## Backups

| What | Where | Verified on the remote? |
|---|---|---|
| assistant workspace | _{{PRINCIPAL_NAME}}'s private repository URL_ | _date + how_ |
| head / bus | _{{PRINCIPAL_NAME}}'s private repository URL_ | _date + how_ |

**A repository with no remote is backed up nowhere.** Check with `git remote -v` — never assume.

## Single points of failure

- _List them. The dangerous ones are the ones that look covered._
