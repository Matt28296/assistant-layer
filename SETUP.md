# SETUP — installing the assistant + head on someone's machine

Two roles in this guide:

- **OPERATOR** — the person installing it.
- **PRINCIPAL** — the person the system works for, on their own machine.

**Steps marked 🔑 PRINCIPAL are signing in or approving. The operator never does them for the
principal** — not by typing their password, not by reading a code aloud. That line is the whole
authority model.

---

## 0. Before the session — collect these answers

| Question | Why it matters |
|---|---|
| Windows or Mac? | which launcher and fill command to use |
| Does the principal have a Claude plan, and which? | the seats run on it |
| Does the principal have a GitHub account? | their private copies live there |
| Which email provider (Gmail, Outlook, other)? | decides how email is connected |
| Which CRM, file storage and team chat — and who holds the admin login for each? | each connection is the principal's sign-in |
| Is the CRM plan able to run automations/workflows? | decides what the CRM does vs what the agents do |

**Anything unanswered here becomes a stop during the session.**

---

## 1. Create private copies — 🔑 PRINCIPAL's GitHub account

**⚠ Do not fork. A fork of a public repository stays public.**

For **each** of `assistant-layer` and `head-orchestrator`:

1. Open the repository on GitHub → **Use this template → Create a new repository**.
2. Owner: **the principal's account**. Visibility: **Private**.
3. Suggested names: `<business>-assistant`, `<business>-head`.

## 2. Install on the machine

- Git.
- Claude Code (official installer, per Anthropic's documentation).
- 🔑 **PRINCIPAL** signs in to Claude Code and to GitHub on this machine.

## 3. Create the folders — siblings, never nested

```
<AGENTS_ROOT>\
    assistant\    <- clone of the private assistant copy
    head\         <- clone of the private head copy
```

```
cd <AGENTS_ROOT>
git clone <private assistant repo URL> assistant
git clone <private head repo URL> head
```

**Put NO `CLAUDE.md` in `<AGENTS_ROOT>` itself.** Claude Code loads it into every session below.

## 3a. Bind the coordination bus

Read `docs/DEPLOYMENT.md`. Choose the existing fleet bus for an existing network; do not create a
competing bus. For a new installation, the private Head remote can be the bus.

Clone the chosen remote into a separate Assistant-owned bus checkout. The Head uses its own exclusive
checkout (the head workspace itself is allowed when its remote is the chosen bus). Record these as
ASSISTANT_BUS_DIR and HEAD_BUS_DIR. Never have both sessions write one working copy.
Initialize a new bus with the template msg/state/identity skeleton; preserve all existing data when
using an established bus. Register measured identities in that bus before launch.

## 4. Measure — never guess

```
hostname
```

Record the exact output, both launch paths, both exclusive bus checkout paths and the Head-readable
PRINCIPAL_MIND_DIR. This setup guide assumes the top seats share a host; multi-host deployments must
bind each seat to its measured host and supply a versioned read-only decision-model snapshot.

## 5. Fill the placeholders

1. Copy `values.example.json` to `<AGENTS_ROOT>\values.json` and fill **every** value.
   Windows paths use doubled backslashes in JSON.
2. Run in **both** repositories with the **same** file:

```
cd <AGENTS_ROOT>\assistant
powershell -ExecutionPolicy Bypass -File tools\fill-placeholders.ps1 -Values ..\values.json
cd <AGENTS_ROOT>\head
powershell -ExecutionPolicy Bypass -File tools\fill-placeholders.ps1 -Values ..\values.json
```

**Mac:** install PowerShell 7 first, then run the same two commands with `pwsh` instead of `powershell`, and `/` instead of `\` in the paths.

**Each must end with `OK - no placeholders left in this repository, and every JSON file parses.`** Anything else: fix the value
it names and run it again. Do not continue on a non-OK result.

## 6. Personalise the brains

- `assistant\principal-mind\core.md` — objectives, priorities, communication style, from discovery.
  **Mark every line `[confirmed date]` or `[inferred]`.** Only the principal's own words are confirmed.
- `assistant\system-brain\core.md` — the tools table and the work stage by stage.
- `assistant\principal-mind\REVIEW-QUEUE.md` — every inference, for the principal to tick.
- Set PRINCIPAL_MIND_DIR to the Head-readable canonical vault or a versioned read-only snapshot.
  Follow `docs/HEAD-LEARNING.md`; the Assistant remains the editor and the Head proposes corrections.

## 7. First launch

1. Start the head: `head\tools\launch-head.cmd` (Mac: `launch-head.sh`).
   **It must pass its identity check.** If it stops, it is right — fix the value it names.
2. Start the assistant: `assistant\tools\launch-assistant.cmd`. Same check.

**Mac:** run `chmod +x head/tools/launch-head.sh assistant/tools/launch-assistant.sh` once, then start each seat with its `.sh` file.

## 8. Round-trip test — prove transport and identity

1. Assistant posts a `→ head` ping from ASSISTANT_BUS_DIR, commits, pushes and verifies the remote.
2. Head synchronizes HEAD_BUS_DIR, reads the ping, answers in its own log, commits and pushes.
3. Assistant synchronizes its own checkout and confirms the reply and identities with timestamps.
4. Mark manually launched seats ATTENDED. VERIFIED-ACTIVE additionally requires a declared,
   measured autonomous cadence and a fresh heartbeat; a ping alone does not prove autonomy.

## 9. Push and verify

Commit both repositories and push. Then **verify on GitHub** that the latest commit is there — a
successful push command is not the receipt; the remote is.

## 10. Connect business tools — 🔑 PRINCIPAL

Each connection (CRM, email, storage, team chat) is made **by the principal** through that service's
own official connection or sign-in screen. **The agents never type or store credentials.**
Record each connection in `CONTINUITY.md`.

## 11. Hand over the first brief

Save it in `assistant\briefs\`, commit and publish to the private Assistant remote. Post its accessible
path and revision through ASSISTANT_BUS_DIR/msg/assistant.md. Synchronize and verify the Head's
acknowledgement in your own bus checkout. Register and validate a real division and worker before
production dispatch; see the end-to-end acceptance exercise in `docs/DEPLOYMENT.md`.

---

## Never

- Fork the public template.
- Put a `CLAUDE.md` in the folder above both seats.
- Sign in, type a password, or read out a code for the principal.
- Commit client documents, bank details or passwords to either repository.
- Mark a seat VERIFIED-ACTIVE without both a round trip and measured autonomous cadence.
