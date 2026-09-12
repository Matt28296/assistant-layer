# LAWS — the failure modes this system paid to learn

Every law below was written **after** something broke. None is a principle someone liked the sound
of. They are kept in one file because the same shapes recur across unrelated subsystems, and a team
that has named a shape recognises it in a new place.

The format is deliberate: **the law, then the mechanism, then the direction it fails in.** The
direction matters more than the rule, because the failures that survive are the ones that fail
*reassuringly*.

---

## 1. A declared cadence is a CLAIM until it is measured

An agent is not active because it says it is. It is active when a **round-trip has been observed**
(you asked, it answered) **and** its heartbeat is fresher than the cadence it claims.

Self-reports are labels, not credentials. So is authorship metadata: in a distributed agent system,
commit authorship is a mutable local setting, and one agent's work has been attributed to another by
nothing more than a misconfigured identity.

**Registry rule:** a new agent is registered UNVERIFIED and stays there until it has answered
something. Registration is not proof. Its own log entry is not proof.

---

## 2. Absence is not evidence — name the instrument's SCOPE in the claim

A probe that returns nothing is not saying "this does not exist." It is saying "this is not in what I
looked at."

**The case that named it:** a health check queried listening sockets and reported two services
UNVERIFIED for three consecutive days. Both were alive the whole time. The service binds its port
without ever calling `listen()`, so a listening-socket query *structurally cannot see it*. The honest
reading of the empty result was never "could not verify" — it was "my instrument's scope excludes
this object."

**Rule:** when a probe returns nothing three times running, suspect the probe. State the scope inside
the claim: not *"no secrets found"* but *"no secrets found by pattern X over directory Y."*

*This law bites its author constantly. A search for a file across the wrong one of three
identically-named directories returns the same empty result as a file that does not exist.*

---

## 3. A guard that fails GREEN outlives every guard that fails loudly

Any check that can report healthy while its subject is dead will eventually do exactly that, and
nobody will file a bug, because nobody objects to good news.

**Instances:**
- A heartbeat file with no expiry. The writer died; the file kept publishing its last healthy value
  for fifty-two days. **Fix: write a `valid_until` beside every timestamp, so a dead writer cannot
  keep publishing a healthy reading.**
- A freshness measure defined as *state-file age minus log age*, where a scheduled job rewrote the
  state file every fifteen minutes regardless of whether the agent did anything. The busiest agent in
  the system **could not be flagged stale. Not "was not" — could not be.** A freshness measure a
  robot can satisfy on the agent's behalf is not measuring the agent.
- A lock file recording *intent* rather than *liveness*: `running: true` for a process that no longer
  exists. It fails green for the thing it guards, because it says "someone is on it."

---

## 4. A guard that fails RED into a channel with no reader is worth the same as one that failed green

The other half of law 3, and the more expensive half to discover.

A scheduled job was built to **fail loudly** — its own source carries the comment *"a delivery step
that fails quietly recreates the exact gap this closes."* It did fail loudly, exactly as designed, by
returning a non-zero exit code. The exit code went to a field nobody reads between daily passes. A
full day of output sat staged and uncommitted.

**An alarm needs an actuator.** A detector whose output nothing consumes is decoration.

**Corollary — read the exit-code CONTRACT per job, never the number alone.** One job in this system
returns `1` to mean *"the thing I watch is late"* — a correct, healthy report. A summary that scored
that `1` as broken missed two genuine failures in the same pass, and so was pessimistic about
recovery and optimistic about health in the same sentence.

---

## 5. A gate downstream of the irreversible action is a receipt, not a gate

If a check runs after the thing it protects against has already happened, it is documentation. If it
only works when someone remembers to run it, it is not protection.

**The case that named it:** a re-render tool copied the original to a backup directory *only if no
backup was already there*, then printed `originals in <dir>` **unconditionally**. Correct on the
first run. On the **second** run of the same item it silently destroyed what it replaced, while
printing a receipt saying originals were kept.

**The guard protected the first occurrence and then reported success for silent destruction.** That
is worse than no backup at all, because no backup keeps the caller careful.

**Rule:** never skip the copy — version it. And make the closing line state **what actually
happened** ("backed up N, skipped 0"), never the name of a directory.

**Corollary — survey the candidate, not just the population.** A detector was built to measure how
many *already-published* artifacts carried a defect. The one artifact about to be published was the
only one nobody had measured. A survey that excludes the candidate is this same law wearing a
lab coat.

---

## 6. Two instruments that disagree about one fact are the most expensive thing you can own

When two numbers describe the same thing and differ, the failure is not that one is wrong. It is that
**both are quotable**, and whoever is arguing will quote the one that helps.

**Fixes that work:**
- Make the display import the *same function* the authority uses, rather than querying independently.
  Two surfaces then cannot disagree about a number.
- When sources disagree, **check whether both are true of different things** before picking a winner.
  A browser reporting one brand's account on one platform and another brand's on a second platform is
  not "unstable over time" — it is two brands resident at once, and reading it as instability threw
  the measurement away for four days.

**Never resolve a disagreement by choosing the fresher number.** Report it as a finding.

---

## 7. A number that cannot express the state it is in will be read as the state it can

A supply counter reported `EMPTY` for a work queue. It was correct. Everyone read `EMPTY` as *"make
more"* and spent nine hours making more.

The real state was *"several items exist, are approved, and are stuck at a later stage."* The counter
had no bucket for that, because its internal checks ran in an order that discarded those items before
the stage that would have counted them. **A missing record and a failed record were indistinguishable
in its output.**

**Rules:**
- **Order the checks so the cheapest, most structural test runs first** — does the artifact exist,
  before whether it passed review.
- **Every discard path gets a counter.** If a function can drop an item, the drop must appear in the
  output.
- **Make the buckets sum to the input**, and fail loudly if they stop summing. Then a future editor
  who adds a discard without a counter breaks a test instead of breaking a decision.
- **`EMPTY` must never be reportable without the reason it is empty.**

---

## 8. Do not infer a function's contract from its identifier

A helper named in the shape of *"path for this item"* answers a narrower question than its name
suggests. Two independent agents read the same name, assumed the same wrong meaning, and reported the
same wrong cause — **without conferring**.

That is what makes it a law rather than an anecdote: when two readers make an identical error from
the same identifier, the defect is in the naming, not in either reader. **Open the function.**

---

## 9. A counter with no cadence ages into a disagreement with its own author

A progress counter had no scheduled run. Its published output sat twenty-two hours old while the
document beside it carried a newer figure. **Both were true when written.** The published one is the
one other systems read.

**Corollary:** prefer adding a step to an existing scheduled job over registering a new one. A second
scheduler entry is a second thing that can silently never fire — which is precisely what the original
job did before anyone checked it.

---

## 10. A time-boxed promise to a human needs a TIMER, not an intention

An agent promised a person a reply "in about twenty minutes." Nothing in the system would fire at
that moment. The mark could only be missed, and it was, by more than the promise itself.

**If you commit to a time, write the deadline somewhere a watchdog reads.**

**And separate the two halves of the promise:** the commitment is usually that the person *hears from
you*, not that the work is complete. Never let the mark pass in silence — deliver if ready, say
"almost ready" if not.

---

## 11. On a machine a human uses, an agent's polling loop is not free — it costs the human

Console applications create windows that take foreground focus. A dashboard that shells out on every
refresh opened **nine console windows in 8.6 minutes** on the owner's desktop and stole his keyboard
mid-sentence while he was typing to a client.

**Rules:**
- **Poll a FILE, not a PROCESS.** If a scheduled job already publishes the measurement, read what it
  published.
- When you must spawn, spawn without a window (`CREATE_NO_WINDOW`, or an equivalent hidden launcher).
- **Fix the window, not the freshness.** The tempting fix was to widen a staleness threshold so the
  expensive path ran less often — which removes the symptom by making the displayed number staler.
  That trades a visible annoyance for an invisible wrong answer.

**And the one that generalises:** do not swap an interpreter for its windowless variant without
checking what the target writes. Where the windowless variant has no standard output, any `print()`
in the target starts raising — silencing a real alarm to cure a cosmetic flicker.

---

## 12. Read to the end of the section before acting on its first clause

An agent held a piece of approved work for eleven hours, citing a rule in its own charter that
forbade an action "outside an already-approved case." **The clause was bounded by that exception, and
the paragraph three lines below it recorded the amendment that settled the question.** It read the
first half of the section, plus the superseded sentence it was reasoning from, and stopped
immediately above the correction written specifically to fix that misreading.

**The caution was still correct** — it asked rather than acted, and the cost was delay rather than a
bad irreversible action. The fix is not "trust instructions more." It is **finish the section.**

---

## 13. The remote is the receipt

Work is not delivered because the command that delivers it returned zero. A local reference that
tracks a remote can be set by your own push and nothing else.

**Verify against the remote itself**, or against a *second* independent copy that fetched the same
state from it. A different clone fetching the same revision is proof; your own tracking reference is
a memory of an intention.

**Related:** *in-session is not on-bus.* Work an agent has done in its own context does not exist to
anyone else until it is published where they read.

---

## 14. A record two documents point at, and nobody has opened, is the same as no record

Neighbouring documents drift, and they drift invisibly because they are updated in the same pass by
the same author. Twice in two days, a fact was held by three documents and missing from the fourth —
and the fourth was the one that answers *"how do I bring this back."*

**Rules:**
- **Cross-read the neighbouring documents before writing "no entry exists."** Checking only your own
  file and calling the absence a fact is law 2 aimed at your own documentation.
- **Note which way an unchecked absence pushes.** "Nobody recorded why this was switched off" argues
  for switching it back on. An absence does not land neutrally.
- **A snapshot that drifts is a reader ruling from a page nobody is looking at.** If consumers read a
  copy, republishing the copy is part of the change, not a follow-up task.

---

## 15. Two writers, one working tree, and the message belongs to whoever committed last

Two sessions sharing one checkout: one staged everything, the other committed seconds later. A large
documentation rewrite landed inside a commit whose message was about something else entirely.
Nothing was lost, and nobody reading the history will ever find it.

**Rule: one checkout per writing session.** Where that is not possible, inspect the change set
immediately before committing, and **commit your own paths explicitly** rather than everything.

---

## 16. Scheduled jobs survive a restart; attended sessions do not

Across three unplanned restarts, every registered scheduled job came back unaided and **not one**
attended working session did. Durability is exactly the fraction of the system that is a scheduled
job — and in most systems that is the monitoring, not the production work.

**Corollary:** a staged update is not a loaded update. Extensions, plugins and long-lived processes
keep the code they started with. Something that "changed on disk this morning" may not take effect
until the next restart — which makes a restart look like the cause of an unrelated fault.

---

## 17. A partial delivery reported as complete is the defect, not the shortfall

"Four of the five are done" is a report. "Done" is a defect. **Report the honest remainder**, and
report it as soon as it is known rather than at the end of a stalled period.

**And name what you could not do rather than omitting it.** An agent that stops and says "I tried
four remedies, here is what each returned, I am not attempting a fifth" has delivered something. One
that quietly keeps retrying has not.

---

## 18. Distinguish NOT ACTING from UNABLE TO ACT — only the agent itself can

From the outside these are identical: no output. From the inside they are completely different
problems, and only the agent knows which it is.

An agent reported dark for hours turned out never to have been started at all — and its first command
was then refused by a permission boundary. Both halves in sequence, invisible from outside.

**Rule:** if you cannot act, say so immediately and name the boundary. Silence gets read as idleness,
and idleness gets escalated to the wrong owner.

---

## 19. Approval is scoped, and the scope is not always the one being discussed

A clearance can be genuine and still not cover the step in front of you. One approval covered *the
item*; a separate question governed *the surface it would be published to*. Both were needed, and
only the second could tell which identity the publication would happen under.

**Name which gate you are clearing.** "Approved" wearing the language of a different gate is how an
approved item lands in the wrong place.

---

## 20. Authority can be delegated; VERIFICATION cannot

When a principal delegates decision-making to an agent, what moves is the right to decide. What does
not move is the requirement for evidence.

**Taking someone's word on AUTHORITY is not the same as taking their word on FACTS**, and nothing
about a delegation licenses the second. Receipts, source checks, and "I do not know" remain required
— from the delegating principal exactly as from anyone else.

---

## 21. Record an accepted risk with an owner and a date, and stop re-litigating it

When a principal is told a risk in detail and accepts it, that is a decision. Write down **what was
accepted, who accepted it, and when.** Raise the residual point **once**, in the record, and never
again.

An agent that re-raises a settled risk every session is not being careful. It is spending the
principal's attention on a question that is already closed, and training them to skim.
