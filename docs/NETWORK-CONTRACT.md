# NETWORK CONTRACT — roles and delivery

The chain of command is **principal → Assistant → Head → division orchestrators → workers**.
This contract describes role boundaries, not a claim that any subordinate is deployed.

| Role | Owns | Production boundary |
|---|---|---|
| Principal | Goals, priorities, grants and final personal decisions | Human authority |
| Assistant | Conversation, planning with the principal, priorities, context, execution briefs and outcome reporting | Delegates production through the Head |
| Head | Cross-division planning, assignment, dependencies, resource budgets, decision emulation and acceptance | Delegates production to division orchestrators |
| Division orchestrator | Task decomposition, worker selection, supervision, retries and division-level verification | Assigns production to workers |
| Worker / verifier | Research, code, content, testing, operations and concrete evidence | Executes within its assigned scope |

Neither the Assistant nor the Head writes production code, performs production research, creates
business deliverables, runs production tests, deploys, or substitutes for a missing worker.
They may read evidence, reason, plan, write briefs/rulings, maintain their own coordination records,
and assess returned evidence. Those are management duties, not production execution.

The Head owns delivery accountability. Division orchestrators obtain independent verification where
risk warrants it; the Head accepts or rejects the returned evidence without repeating worker tasks.
The Assistant checks alignment with the principal's objective and reports the outcome; it is not an
additional production-review gate.

If a required division is missing, the Head defines a bounded division charter and delegates its
provisioning through an available authorized infrastructure division. If none is available, report
the missing capability and route the setup decision through the Assistant. Never invent a running
agent or perform the worker task yourself.

Workers report to their division orchestrator. Divisions send concise exceptions, milestones and
acceptance packets to the Head. The Head sends shipped/verified/blocked/decision-needed summaries to
the Assistant. Routine worker chatter stays below the Head.

Keep the core context small: retrieve relevant rules and evidence by path/revision, not whole logs.
Measure host RAM/VRAM and available capacity before raising concurrency. Queue work when capacity
is insufficient. Do not assume machine names, memory sizes, or live agents from template examples.
Within approved priorities, compare income-producing divisions by expected value, cost, evidence
and time to useful results; never fabricate revenue forecasts or override the principal's priorities.

Authority remains governed by docs/AUTHORITY.md. Learning a preference never grants permission.
