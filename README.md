# O

**Private AI operations companion for the Otya ecosystem.**

O is the owner-only AI application for coordinating engineering, product development and company operations across the Otya ecosystem. The product is **O**; its conversational assistant persona is **Leo**.

O is not a shared public chatbot, a second product database or an unrestricted administrator. It connects to OEnd through authenticated, narrowly scoped APIs and keeps owner memory separate from every product's customer context.

## Product boundaries

- **OPoint** — retail and business operations. O may inspect approved company/branch-scoped read models and prepare recommendations; it cannot initiate payments or post financial records.
- **Omy Play** — local-first media. O cannot scan or upload local libraries, Private/Vault files, playback history or device paths.
- **OEnd** — identity integration, model routing, policy enforcement, tool gateway and approved shared services.
- **Otya ID** — shared identity and OTP. Telegram is not a login provider; a linked bot may deliver a requested code after email identity verification.
- **Otya Control** — private administration and operations, with stricter permissions than normal product workspaces.
- **OHub** — public developer documentation. O never publishes private owner context, secrets or internal runbooks there.

## What O does

- Understands goals and gathers evidence from approved sources.
- Reads repository, CI, staging-health and operational status.
- Plans work across products while respecting their ownership boundaries.
- Creates reviewable code, documentation and test changes.
- Runs safe, read-only checks and verifies their results.
- Drafts migration plans, incident reports and release evidence.
- Prepares sensitive actions for explicit owner approval.

O may autonomously inspect, test and prepare a change. It must not silently merge release-critical code, deploy production, publish releases, send broadcasts, move money, change security policy, grant privileges or delete production resources.

## AI architecture

- The Android app is a secure client; model orchestration and privileged tools stay server-side in OEnd.
- Workers AI is the default inference path where quality and latency tests support it.
- AI Gateway provides provider routing, fallback policy, cost controls and observability.
- Durable Objects provide durable agent/session state where needed.
- D1 stores structured conversation metadata, approvals and audit references; R2 stores private generated artifacts.
- Product knowledge and owner memory use separate namespaces and retrieval policies.
- Voice is an optional transport; microphone audio is not continuously uploaded for wake-word detection.
- A missing model/provider must not disable O's safe local app functions or compromise authorization.

## Memory and product isolation

O has its own private owner memory. It is not automatically available to OPoint users or Omy Play users.

Each product assistant, when separately enabled, receives its own conversation namespace, retrieval corpus, prompt version, tool registry, rate limit, usage budget, audit context and retention policy. No cross-product memory search or D1 access is allowed by default.

The model never decides who the user is or what the user may access. OEnd verifies identity and owner permissions; the owning product API enforces tenant and branch authorization on every request.

## Permission levels

| Level | Capability |
|---|---|
| Read | Inspect approved health, status, repository and business read models |
| Draft | Prepare code, configuration, reports and proposed operations for review |
| Approved action | Execute a narrowly typed action after fresh owner authorization and any required step-up |
| Restricted | Money movement, irreversible deletion, security/identity changes, production deployment and public release publication |

Every approved action must record the principal, scope, target, approval, idempotency key, outcome and timestamp. On missing permission, stale state or uncertain provider outcome, O fails closed.

## Technology

### App
- Flutter/Dart with feature-first architecture and Riverpod.
- Android native Kotlin for assistant-role integration, voice sessions and device capabilities.
- Android secure storage and biometric step-up for sensitive approvals.
- FCM only for safe notification hints; the app fetches authoritative state from OEnd.

### Backend
- Cloudflare Workers and Agents SDK for orchestration.
- Durable Objects for agent sessions and real-time communication.
- Workers AI and AI Gateway for controlled inference.
- D1, R2, Queues and Workflows for durable state and bounded background tasks.
- Resend through OEnd for transactional email.

## Security

Never bundle or commit Cloudflare API tokens, Firebase Admin credentials, Resend keys, GitHub tokens, provider secrets, signing keys or owner access tokens. User-supplied instructions and retrieved documents are untrusted data, not policy.

The existing Android application ID is retained as a compatibility identity until its distribution and signing status are verified. Product display name and code branding are **O**.

See [AI product boundaries](docs/AI_PRODUCT_ISOLATION.md) and [architecture](docs/ARCHITECTURE.md).
