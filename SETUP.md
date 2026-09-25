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

Then give git the name and email its commits will carry. Without them, git stops at the first commit:

```
git config --global user.name "<name>"
git config --global user.email "<email>"
```

Every commit pushed to GitHub shows that email. To keep a personal address out of the history, use
the account's GitHub no-reply address (GitHub → Settings → Emails).

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

## 4. Measure — never guess

```
hostname
```

Record the exact output, and the exact full paths of `assistant\` and `head\`.

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
(The Mac path has not yet been run end to end.)

**Each must end with `OK - no placeholders left in this repository, and every JSON file parses.`** Anything else: fix the value
it names and run it again. A refused run writes nothing, so the templates are still as they were. Do not continue on a non-OK result.

Before it writes anything, the filler also checks the machine values against the machine: `HOSTNAME`
must be exactly what `hostname` prints, `ASSISTANT_DIR` and `HEAD_DIR` must be two different folders
directly inside `AGENTS_ROOT`, and the repository it runs in must be one of them.

**A value turns out wrong after an OK fill?** Running the filler again does not change it: no
placeholders are left, so it stops with `NOT DONE - nothing to fill` and writes nothing. While nothing
is committed or hand-edited yet, put the templates back in both repositories, fix `values.json`, and
run both fill commands again:

```
cd <AGENTS_ROOT>\assistant
git checkout -- .
cd <AGENTS_ROOT>\head
git checkout -- .
```

## 6. Personalise the brains

- `assistant\principal-mind\core.md` — objectives, priorities, communication style, from discovery.
  **Mark every line `[confirmed date]` or `[inferred]`.** Only the principal's own words are confirmed.
- `assistant\system-brain\core.md` — the tools table and the work stage by stage.
- `assistant\principal-mind\REVIEW-QUEUE.md` — every inference, for the principal to tick.

## 7. First launch

Before either seat starts, commit the filled templates once in each repository, so both seats start
on a clean tree. Once a seat is running, it commits only its own paths:

```
cd <AGENTS_ROOT>\assistant
git add -A
git commit -m "setup: filled from the template"
cd <AGENTS_ROOT>\head
git add -A
git commit -m "setup: filled from the template"
```

1. Start the head: `head\tools\launch-head.cmd` (Mac: `launch-head.sh`).
   **It must pass its identity check.** If it stops, it is right — fix the value it names.
2. Start the assistant: `assistant\tools\launch-assistant.cmd`. Same check.

**Mac:** run `chmod +x head/tools/launch-head.sh assistant/tools/launch-assistant.sh` once, then start each seat with its `.sh` file.

The first time Claude Code starts in each folder, it asks whether to trust that folder, and the seat
does not start until someone at the machine accepts. Claude Code also asks permission before a seat
edits files or runs most commands, and before the assistant writes into `head\`, which is outside its
own folder. Someone at the machine answers these prompts; no other seat can.

## 8. Round-trip test — the only proof both seats work

1. In the assistant: *"Post a `→ head` ping in the bus asking the head to confirm its identity check."*
2. In the head: *"Read msg/assistant.md and answer the newest `→ head` entry."*
3. Confirm **both entries exist in the files**, then mark both seats `ATTENDED` in
   `assistant\state\AGENT-REGISTRY.md` **with the time**. Both are attended sessions with no declared
   cadence, so `VERIFIED-ACTIVE` does not apply (see the status table in that file).

## 9. Push and verify

The seats committed their own files in the head repository during step 8. In `assistant\`, commit
what changed there (at least the registry update from step 8). Then push both repositories, and
**verify on GitHub** that the latest commit is there — a successful push command is not the receipt;
the remote is.

Do not `git add -A` in `head\` once a seat has started there: it commits the other seat's
half-written work under your message.

## 10. Connect business tools — 🔑 PRINCIPAL

Each connection (CRM, email, storage, team chat) is made **by the principal** through that service's
own official connection or sign-in screen. **The agents never type or store credentials.**
Record each connection in `CONTINUITY.md`.

## 11. Hand over the first brief

Save it in `assistant\briefs\`, post `→ head` in `head\msg\assistant.md` with the brief's full path,
and watch for the head's acknowledgement in `head\msg\head.md`.

---

## Never

- Fork the public template.
- Put a `CLAUDE.md` in the folder above both seats.
- Sign in, type a password, or read out a code for the principal.
- Commit client documents, bank details or passwords to either repository.
- Mark a seat active before step 8 has passed.
