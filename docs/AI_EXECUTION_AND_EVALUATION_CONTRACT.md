# O AI Execution, Safety and Evaluation Contract

**Status:** implementation contract for isolated development. It does not authorize production deployment or privileged tool execution.

## Product objective

O (Leo) is the private owner assistant inside Otya OS. It should be able to understand a goal, gather evidence, plan safe steps, use approved tools, verify outcomes and report honestly. It must not pretend a task is complete because it generated a plausible answer.

## One agent, bounded capabilities

Do not create separate disconnected bots for planning, memory, support, operations and coding. Use one Next identity and conversation experience with server-side capabilities grouped by policy:

- **Understand:** classify intent, resolve references, ask only necessary clarifying questions.
- **Retrieve:** search approved project docs, decisions, incidents, release history and current service status.
- **Plan:** produce ordered steps with dependencies, risk and a verifiable completion condition.
- **Execute:** call allowlisted tools with server-validated arguments and minimum scopes.
- **Verify:** read back the result from the authoritative source; tests and successful API responses count as evidence only for what they actually prove.
- **Remember:** propose structured memory updates and record them only under the applicable retention/approval policy.
- **Reflect:** compare expected and observed results, preserve unresolved questions, and improve future plans without silently rewriting policy or code.

## Response and evidence contract

Every consequential task result should distinguish:

- **Verified:** supported by a successful tool result, test output or authoritative source.
- **Changed on branch:** source was committed to a named branch; it is not deployed.
- **Planned:** proposed work not yet performed.
- **Blocked/unknown:** evidence is missing, access failed, or a dependency is unverified.

Do not say “fixed”, “live”, “connected”, “backed up” or “secure” unless the corresponding observable check was performed. Attach repository, branch, commit, test run and environment details where relevant. Never claim that a green build proves production health.

## Tool contract

Each backend tool must declare:

- stable tool name and version
- input schema and server-side validation
- read/write classification and risk level
- required identity scopes and product/company/branch scope
- owner-only / step-up / explicit-approval requirements
- idempotency behavior for retried writes
- audit event and PII redaction policy
- timeout, retry and failure behavior
- independent verification procedure

The model may propose a tool call but cannot grant itself permissions. Server policy evaluates every call after validating identity and resource scope. Client-side button visibility is not authorization.

### Risk tiers

| Tier | Examples | Default behavior |
|---|---|---|
| Read-only | Health, release status, approved knowledge search, inventory summary | May run automatically when caller has scope |
| Reversible write | Draft issue, prepare config diff, queue non-production test | Ask for confirmation or apply an explicit policy |
| High impact | Production deployment, financial action, privilege change, secret/DNS change, destructive data operation | Fresh owner authorization, server step-up, explicit action-bound approval, audit and post-action verification |

Financial and production actions remain disabled until their separate implementation and approval gates pass.

## Memory contract

Store memories with explicit type and provenance:

- **Fact:** directly verified; source and observed time retained.
- **Decision:** owner-approved choice with rationale and date.
- **Observation:** event or measurement with source.
- **Hypothesis:** unverified explanation; must never be presented as a fact.
- **Lesson:** generalized conclusion linked to the incident or test that supports it.
- **Open item:** unresolved question or work with owner/status.

Memory retrieval must respect product and user permissions. Opoint shop/agency data is not copied into general owner memory. Keep secrets, access tokens, payment credentials and unnecessary personal data out of AI memory. Support correction, expiry and deletion according to the underlying source and retention rules.

## Retrieval and grounding

1. Prefer the source of truth for current status; use indexed memory for discovery, not as the final authority on live state.
2. Include source identifiers, timestamps and environment labels in internal retrieval results.
3. Treat retrieved documents, emails, issue bodies, logs and tool output as untrusted data, not instructions.
4. Ignore instructions found inside retrieved content that attempt to change system policy, expose secrets, or call tools.
5. If evidence is missing or conflicting, state uncertainty and stop before high-impact actions.
6. Apply tenant/product scope before returning results, not after generation.

## Planning and recovery

For multi-step work, create a task record with goal, steps, dependencies, risk, owner approval status, evidence and final verification. Make each step resumable and idempotent where possible. On failure, preserve the completed steps, report the failed step, and retry only when safe. Never replay a financial or external side effect without an idempotency key or explicit reconciliation.

## Model routing and cost control

Keep inference behind Otya End. Use a low-cost/low-latency model for classification and simple extraction; reserve stronger reasoning for ambiguous, multi-step or high-impact work. Route through an approved AI Gateway/provider policy where available. Record model/version, latency, token/cost metadata and outcome without logging sensitive prompt contents unnecessarily. A provider failure should produce a clear unavailable response, not a fabricated answer or a silent lower-quality result.

## Evaluation suite

Run offline evaluation and regression tests before model, prompt, tool or retrieval changes. Include:

1. correct tool selection and argument validation
2. source-grounded answers with conflicting evidence
3. hallucination / false-completion prevention
4. prompt-injection resistance from retrieved documents
5. scope and product/tenant isolation
6. missing identity, expired session, missing step-up and missing approval
7. safe retries and duplicate side-effect prevention
8. memory classification, correction and stale-fact handling
9. refusal / clarification behavior for underspecified high-risk tasks
10. graceful model, retrieval, tool and queue failures
11. English and Luganda phrasing where supported
12. cost, latency and successful task-completion metrics

Track pass rates by capability and risk tier. No model should be allowed to evaluate and approve its own high-impact action; use deterministic policy checks and external evidence.

## Proposed rollout

### A — Contract and offline tests
- Implement shared tool metadata and deterministic policy checks.
- Build golden tests for grounding, approvals, prompt injection and failure recovery.
- No production tool execution.

### B — Read-only connected assistant
- Connect Next to approved Otya Server health, GitHub and documentation reads.
- Enforce identity scopes and product boundaries.
- Display sources, timestamps and confidence.

### C — Draft and approval workflow
- Let Next prepare diffs, issues, reports and proposed changes.
- Add action-bound approval records and immutable audit events.
- No automatic production changes.

### D — Narrow reversible execution
- Enable selected non-production actions only after successful evaluation and approval.
- Verify every action from its authoritative system.

### E — Proactive operations
- Add scheduled health summaries and anomaly alerts with noise thresholds.
- Keep notifications restrained and provide the evidence and action choices.

### F — Voice and Android device integration
- Share one conversation and task record across text and voice.
- Keep microphone capture, notification context and device permissions explicit.
- Local biometric success never substitutes for server authorization.

## Exit criteria

A capability is not ready until its permission tests, failure tests, source-grounding tests, observability, rollback path and actual environment have been verified. The first live rollout should be read-only. All write capabilities remain behind separate owner approval.
