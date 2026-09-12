# RESTART — how to bring each part back

---

# CURRENT AS OF {{SETUP_DATE}} — READ THIS FIRST

**Everything below this block is older. Where they conflict, this block wins.**

Both seats are attended sessions: **after the machine restarts, neither comes back on its own.**

---

## assistant

```
WHERE          {{HOSTNAME}}  {{ASSISTANT_DIR}}
CLASS          attended session
BRING IT BACK  double-click {{ASSISTANT_DIR}}/tools/launch-assistant.cmd   (Mac: launch-assistant.sh)
WHO            anyone at the machine
CONFIRM IT     it passes its identity check, and writes a new line in {{HEAD_DIR}}/msg/assistant.md
STATE          measure it; write the time
RESUME POINT   read HANDOFF.md, then state/WORLD-MODEL.md
```

## head

```
WHERE          {{HOSTNAME}}  {{HEAD_DIR}}
CLASS          attended session
BRING IT BACK  double-click {{HEAD_DIR}}/tools/launch-head.cmd   (Mac: launch-head.sh)
WHO            anyone at the machine
CONFIRM IT     it passes its identity check, and writes a new line in {{HEAD_DIR}}/msg/head.md
STATE          measure it; write the time
RESUME POINT   read state/head.json current_work, then the newest → head entry in msg/assistant.md
```

---

## Rules for keeping this file honest

- **Every new component gets an entry the day it exists.** A component with no entry is a bug.
- **CONFIRM IT must not be the thing that lied.** Watch a log line appear — don't just look at a screen.
- **Enumerate everything without a filter** before writing "there is nothing else."
- **Where something could not be checked, write UNVERIFIED** — not a plausible value.
- **A resume point nobody acts on is a note on an empty chair.** If it ages, escalate the restart.
