# EXECUTION BRIEF — adaptive model routing after Claude reset

- **Brief ID:** `2026-10-08-adaptive-model-routing`
- **From:** assistant · **To:** head
- **Status:** DRAFT — prepared for delivery through the Assistant's authoritative bus checkout

---

## Objective

Replace the temporary Claude emergency throttle with an adaptive, hierarchy-aware model-routing policy as soon as Claude capacity returns after Matthew's available reset.

## Why it matters

Claude is the Head Orchestrator. Its limited allowance should produce high-value planning, judgment, exception handling and acceptance while other subscribed, free-cloud and local agents carry bounded production work. The fleet should use all available allowances together without paid API consumption.

## Context

Matthew confirmed the governing preference on 2026-10-08. Source:
`principal-mind/confirmed/2026-10-08-model-routing-and-reasoning.md`.

The current throttle was a temporary response to high Claude Max usage. It must not become the default after capacity returns.

## Scope

**In:**
- End the temporary emergency throttle when the available Claude reset restores capacity.
- Implement adaptive routing by hierarchy, task complexity, consequence, privacy, current allowance pressure and recent verification results.
- Balance subscription-included Claude, Codex/GPT and Grok access, free cloud models, and local Ollama models that are actually connected and permitted.
- Preserve independent verification and compact upward reporting.
- Measure allowance pressure without treating a subscription as paid API entitlement.

**Out:**
- Paid API enablement or API-key assumptions.
- Any weakening of authority, approval, security or evidence requirements.
- Moving production work into the Assistant or Head seats.

## Requirements

1. Preserve the hierarchy: Matthew → Assistant → Head → division orchestrators → workers/verifiers.
2. The Assistant and Head plan, route, rule, review and accept; they do not perform production.
3. Set reasoning floors by layer:
   - **Head:** strongest available reasoning for portfolio decisions, DAG design, cross-division conflicts, risk, exceptions and final acceptance.
   - **Division orchestrators:** strong task-domain reasoning for decomposition, worker choice, synthesis and quality control.
   - **Workers:** the cheapest task-fit permitted model that can meet explicit acceptance criteria.
   - **Verifier:** independent from the producing worker; raise model strength when consequence or ambiguity requires it.
4. Prefer deterministic tools for mechanical checks, then local/free agents for bounded work, then subscription agents for complex work. Escalate on failed checks, repeated failure, architectural risk or high consequence.
5. Send compact execution packets downward and compact evidence packets upward. Do not load raw histories or full artifacts into Claude unless the decision requires them.
6. Track provider allowance pressure separately. Rebalance work away from a near-cap pool before slowing unrelated work.
7. Do not silently downgrade a layer below its required reasoning floor. If the required model is unavailable, report a blocker or use an explicitly approved equivalent.
8. Use only subscription-included access, free-cloud access or local models. Never enable or consume paid APIs.
9. Use acceptance rate, rework, latency and allowance consumption to refine routing. Do not optimize token count at the expense of accepted outcomes.
10. Preserve current project priorities unless Matthew changes them.

## Constraints

- All hard lines in `CLAUDE.md` §6 apply.
- No account, credential, payment, public-posting, deployment or destructive action is authorized by this brief.
- An available reset may be used by Matthew; agents must not operate account controls or claim the reset occurred without evidence.
- A heartbeat, dispatch or model response is not delivery. Require artifacts and checks.

## Done looks like

- The temporary throttle is shown as released only after fresh evidence that capacity returned.
- A versioned routing policy/config expresses the hierarchy reasoning floors and provider order.
- At least four dry-run cases pass:
  1. simple bounded task routes to a local/free worker;
  2. normal coding task routes to an appropriate subscription worker;
  3. architectural/high-consequence task retains strong Head reasoning;
  4. near-cap provider causes rebalancing without fleet-wide throttle when safe capacity exists elsewhere.
- No paid API lane is enabled.
- Each test includes the selected layer/model class, reason, allowance state, acceptance check and fallback.
- The Head returns the artifact links, revisions, verification evidence and honest remainder.

## Resources

- Confirmed policy note in `principal-mind/confirmed/`.
- Existing connected subscription, free-cloud and local model lanes.
- Current fleet state and measured provider allowance information.
- Existing division orchestrators, workers and independent verifier roles.

## Authority level

Level 3: reversible configuration and policy changes inside the established agent system. Account actions, money, credentials, external sends and deployment remain outside scope.

## Needs Matthew's approval before

- Enabling any paid or metered API.
- Adding or changing subscriptions.
- Entering credentials or changing account settings.
- Lowering a reasoning floor for high-consequence decisions.
- Changing project priorities beyond capacity-aware scheduling.

## Open decisions

None for the stated policy. Use the existing priority order and current connected model inventory. If two permitted models satisfy the same floor, choose the one with more available allowance and lower opportunity cost.

## Report back

Report through `msg/head.md` only when:
- the reset/capacity return is measured and the temporary throttle is released;
- the routing policy and dry runs are verified;
- a real blocker requires Matthew.

Each report must state: shipped · checked · current allowance evidence · blocked · honest remainder.

## Delegation and receipt

Head assigns the routing implementation and tests to the appropriate division orchestrator; division orchestrators assign workers and an independent verifier. Neither top seat performs production. The Head acknowledges the delivered brief revision before dispatch.
