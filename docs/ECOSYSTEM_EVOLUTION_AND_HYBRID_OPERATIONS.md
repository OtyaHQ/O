# Otya Next — Ecosystem Evolution and Hybrid Operations

**Status:** architecture and delivery contract. This document authorizes planning, reviewable code changes and read-only monitoring; it does not authorize production deployments, financial actions, destructive changes or privileged actions without explicit approval.

## Mission

**Product identity:** OtyaPoint is the public product name for the shop and business-operations experience. This architecture document describes product boundaries and does not assert legal registration, ownership or trading-name status.

Otya Next is the owner's AI coordinator for the whole Otya ecosystem, not an OtyaPoint-only assistant. It should coordinate discovery, planning, execution, verification and reporting across OtyaPoint, Otya End, Otya Media, OtyaHub, Cloudflare, GitHub, Resend and approved partner integrations.

Otya Next must not become a second backend. It is the conversational owner interface and orchestrator. Shared APIs, policy enforcement, product data and audit records remain server-side in Otya End and each product's bounded service.

## Ecosystem service map

| Domain | Responsibility | Otya Next's permitted role |
|---|---|---|
| Otya OS | Shared product experience and identity principles | Cross-service status, decisions and coordination |
| Otya End | Shared backend, auth contracts, notifications, recovery and integration boundaries | Call documented, scoped APIs; never bypass product authorization |
| OtyaPoint | Shop: inventory, POS, mobile-money agency, airtime/data, bills, float and reconciliation | Read scoped status, prepare reports, draft actions; financial execution requires explicit action-bound approval and provider truth |
| Otya Media | Local-first audio/video, Send, Private, releases and optional Together services | Monitor builds/releases and investigate crashes; never make playback depend on AI or cloud |
| OtyaHub | Public docs, developer/partner information, safe examples and release notices | Draft public-safe documentation; never publish secrets or internal operational details |
| Cloudflare | Workers, D1, R2, KV, Queues, Workflows, AI, observability and access controls | Inspect permitted state, prepare diffs and verify results; production writes remain gated |
| GitHub | Source, issues, pull requests, CI, releases and security findings | Inspect, validate, create branches/PRs and summarize; merge/release policy is separate |
| Resend | Transactional email, delivery events and webhooks | Inspect delivery status and prepare templates; broadcasts and configuration changes require approval |
| Payment partners | InterSwitch Marketplace Routing, Quickteller Business, Airtel Money, MTN Mobile Money and future replaceable providers | Use sandbox contracts and reconciled status only; never fabricate success or expose credentials |

## Hybrid intelligence model

Hybrid means multiple cooperating execution modes behind one Otya Next identity, not a collection of disconnected bots:

1. **Fast path:** deterministic rules and lightweight models for routing, simple retrieval, status summaries and low-risk tasks.
2. **Reasoning path:** a stronger model for multi-step planning, ambiguity resolution, cross-repository design and incident analysis.
3. **Tool path:** typed, allowlisted server-side tools for GitHub, Cloudflare, Resend and product APIs, each with schemas and least-privilege scopes.
4. **Local/device path:** Android voice entry, notifications, biometric step-up and safe device actions; no infrastructure credentials in the APK.
5. **Durable workflow path:** Workflows/Queues for long tasks, retries, reconciliation and resumable operations. User-facing status must distinguish running, completed, failed and awaiting approval.
6. **Knowledge path:** source-grounded retrieval from approved docs, decisions, incidents and product-scoped records. Indexed memory is for discovery; current source-of-truth reads decide live status.
7. **Fallback path:** when an AI provider, tool, network or service is unavailable, degrade to explicit status, queue/retry safe work or request approval. Never silently bypass authorization or invent results.

Provider routing must be configurable and observable. Keep model/provider credentials server-side. Do not assume one provider, model or region is always available. Never send sensitive business data to a provider without an approved policy.

## Autonomous evolution loop

For every consequential task: observe the authoritative source; separate verified facts from hypotheses; plan dependencies, risk, rollback and acceptance criteria; execute safely on isolated branches; verify independently; record lessons/open items; report what changed and what remains blocked.

Otya Next must not mark a task complete because it generated a plan, opened a PR, received an HTTP 200, or saw a successful build. Verification claims must match exact evidence.

## Approval and autonomy tiers

- **Tier 0 — observe:** read approved repositories, workflow results, public health, delivery events and service summaries.
- **Tier 1 — reversible engineering:** create branches, edit non-secret docs/tests, run non-production checks, open PRs and update issue records.
- **Tier 2 — scoped non-production writes:** change isolated development resources only when target and rollback are explicit and credentials/scopes permit it.
- **Tier 3 — sensitive operations:** production deployments, DNS/secrets/access policy, user data changes, identity/role changes, official releases, broad public communications and money movement require explicit, action-bound owner approval and server-side step-up.
- **Never:** expose credentials/tokens, bypass product authorization, falsify provider success, hide failures, or leak private source/data through public surfaces.

A phone biometric is not sufficient authorization by itself; the server validates the grant, scope, expiry and action binding.

## Mobile-money and financial safety

Otya Next may explain, prepare and monitor agency operations. It may not invent balances, post success from a browser response, or autonomously move money. A future financial action must include product/company/branch and operator scope; transaction type, amount, currency, provider reference and idempotency key; server-side limits; provider adapter and authenticated request; signed callback verification or trusted status query; durable states including pending/unknown/confirmed/failed/reversed; separate cash, float, commission, settlement and retail ledgers; duplicate/timeout/reversal/reconciliation controls; immutable audit record; and human approval appropriate to the risk.

If a provider times out, the transaction is unknown/pending, not automatically failed or successful. Reconcile before retrying any action that could duplicate a financial operation.

## Hybrid reliability and privacy

- Product services remain independently deployable; one outage should not take down unrelated core features.
- Queue only durable, idempotent work; use bounded retries, dead-letter handling and operator-visible recovery.
- Keep local-first Otya Media playback independent of cloud availability.
- Cache only data safe for the user's scope and defined retention period.
- Never put secrets, raw payment credentials, unnecessary identity data or private shop records in general semantic memory.
- Keep product authorization, company/branch scope and audit lineage through every tool call.
- Redact logs and telemetry; do not transmit notification/device data without OS permission and an approved data policy.
- Every integration needs timeouts, retry limits, rate limits, fallback/health status and ownership documentation appropriate to its risk.

## Ecosystem-wide release acceptance

A cross-service release is ready only when the exact branch/commit and impacted services are identified; security/dependency checks run with usable logs; contract and integration checks pass; stateful changes have verified backup/restore; access scopes and audit events are verified; timeout/duplicate/degraded-network behavior is addressed; rollback is documented; owner approval is recorded for high-impact steps; and post-change state is independently verified.

## Implementation sequence

1. Establish one service registry and dependency/owner map.
2. Expand Otya Next's unified status, incident, approval and activity views over existing scoped APIs.
3. Keep tool calls typed, policy-checked, idempotent and auditable.
4. Maintain cross-repository CI reporting that distinguishes runner initialization failures from source-code failures.
5. Complete Otya Auth and product-scoped authorization contracts.
6. Finish OtyaPoint retail and agency data integration, then provider readiness.
7. Keep Otya Media startup and local playback robust under backend/provider failure.
8. Add scheduled health summaries and recovery drills through approved Cloudflare Workflows/Queues.
9. Maintain evaluations for groundedness, tool safety, authorization, recovery and cross-product regression.

No production feature is considered delivered until its implementation and acceptance evidence exist.
