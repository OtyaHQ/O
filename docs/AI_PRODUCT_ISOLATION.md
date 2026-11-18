# Otya AI platform — product isolation and permission model

**Purpose:** define AI responsibilities across Otya without allowing a language model to become an identity, financial, or production authority.

## AI products

### O — private owner agent

O is the private owner-facing AI coordinator. It can inspect approved engineering and operational signals, explain issues, draft changes, run read-only checks and prepare reviewable pull requests. It may coordinate product specialists but it is not a shared public chatbot and must not expose owner tools to normal product users.

### Opoint Copilot

Opoint Copilot is a separate, tenant-scoped business assistant. The first release is read-only: answer questions about the authenticated company's stock, sales, expenses, cash sessions and business reports using the Opoint API's authorized views. It may prepare draft recommendations such as reorder suggestions or reconciliation explanations.

It must not initiate payments, alter cash, post ledger entries, edit inventory, approve refunds, grant staff permissions or change provider credentials. Any future write action must be implemented as a deterministic Opoint API command with explicit authorization, idempotency, audit trail and human approval—not as a direct model/database write.

### Omy Play intelligence

Omy Play has no requirement for online AI. Local playback, search, scanning and file operations stay local and available offline. Any future assistant should be opt-in, clearly separated from playback, and must not upload a user's local library, media paths or Private/Vault content. It has no access to Opoint business data or owner administration.

## Execution architecture

- Otya End provides a shared inference gateway and provider adapters; it does not share product conversation memory.
- Each product assistant has its own audience, policy, retrieval index, memory namespace, rate limits, telemetry labels and tool allow-list.
- O authenticates as the owner and invokes explicit product-scoped tools.
- Opoint Copilot authenticates as the current end-user and company membership; the server derives tenant and branch scope from verified identity.
- Omy Play AI, if enabled, receives only the minimal user-provided query and approved help content.
- Provider keys remain server-side. Mobile apps call only the product-owned API.

## Permission model

1. **Read-only:** query approved, tenant-filtered views; summarize, explain and compare.
2. **Draft:** prepare a proposed change, but do not apply it.
3. **Approved command:** server validates current state, identity, role, approval and idempotency before executing a pre-defined command.
4. **Restricted:** payments, refunds, posted ledger mutations, account deletion, access grants, secret rotation, production deploys, legal/public commitments and irreversible resource deletion require explicit human authorization and may remain non-automatable.

The language model never decides whether the caller is authorized. The owning API enforces that decision on every request. Tool schemas must be narrow, typed, bounded and tenant-bound. User-supplied instructions and retrieved content are untrusted data, not policy.

## Memory and knowledge

- No global shared memory across O, Opoint and Omy Play.
- Owner memory belongs only to O and is not automatically visible to customer products.
- Opoint business knowledge is generated from authorized company records and verified Opoint documentation; another company's records are never retrieved.
- Omy Play help knowledge contains product support material only, not media-library contents.
- Source facts should be cited or identified in responses. If evidence is absent, the assistant says so rather than inventing records or capabilities.
- Keep operational logs minimal and redact tokens, OTPs, financial identifiers and personal data.

## Model routing

Use the shared inference gateway for provider selection, fallbacks, timeouts, model allow-lists, cost telemetry and observability. Prefer a low-cost model for straightforward help, retrieval and classification. Escalate to a stronger model only for genuinely difficult reasoning and only when policy allows. Model IDs are configuration, not public product guarantees.

Provider availability and price can change. Before selecting any paid or external model for production, evaluate commercial terms, data handling, regional latency, reliability, tool-calling quality and cost per successful task. Offline media functionality must remain independent of inference availability.

## Approval and audit

- AI may autonomously perform read-only checks and run tests.
- Documentation, tests and draft branches may be updated through reviewable changes.
- AI must not silently merge release-critical code, deploy production, publish official releases, send broadcasts, alter security policies, initiate money movement or delete production records/resources.
- Every approved command records principal, product, tenant, action, target, approval reference, idempotency key, outcome and timestamp.
- On ambiguous identity, missing authorization, stale state, provider uncertainty or contradictory source evidence, fail closed and ask for human review.
