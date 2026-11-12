# Otya Next

**Otya Next** is the private owner intelligence application within the Otya ecosystem.

It is not a second backend and it is not a browser admin dashboard. Otya Next is the secure Android-first interface to the existing OTYA intelligence and operations plane: conversation, voice, approvals, incidents, support, releases, system health, connected services, memory and device actions.

## Product direction

Otya Next should feel like a persistent intelligent partner rather than a command console:

- natural text and real-time voice conversation
- interruption / barge-in during voice replies
- stable personality: friendly, professional, calm and lightly humorous when appropriate
- persistent context and operational memory
- proactive but restrained notifications
- system awareness across Otya services
- reflection, verification and confidence-aware answers
- owner-only action approvals and biometric step-up
- Android assistant role and device capabilities where the OS permits them
- no secrets or infrastructure credentials stored in the APK

## Technology

### App

- Flutter 3.47.x / Dart for the primary UI and feature architecture
- Riverpod for application state and dependency injection
- go_router for navigation and deep links
- Dio + WebSocket for authenticated REST and real-time agent sessions
- Android Kotlin for assistant-role, voice interaction, notification access and device-level capabilities
- Android BiometricPrompt through Flutter local_auth for sensitive approvals
- Firebase Cloud Messaging for proactive owner alerts when the app is not active

### Backend

Otya Next connects to the existing Otya End backend and approved Cloudflare services. Server-side intelligence remains server-side.

Target backend building blocks:

- Cloudflare Workers / existing Otya services
- Cloudflare Agents SDK + Durable Objects for durable agent identity, state and real-time sessions
- Workers AI for default inference
- AI Gateway for observability, fallback/routing and provider control
- Cloudflare Voice for real-time STT / LLM / TTS transport where appropriate
- AI Search / Vectorize for private product and long-term semantic knowledge
- Workflows for durable multi-step operations
- D1 / Durable Object SQLite for structured state and audit history
- R2 for larger owner artifacts and reports
- FCM for Android wake-up notifications and urgent incident delivery

## Security boundary

The public Omy Play and other public surfaces must never inherit Otya Next owner permissions.

Otya Next uses the normal Otya identity, then obtains a separate short-lived owner authorization after server-side role checks and step-up verification. High-impact operations require explicit approval and may require fresh biometric/server verification.

Never commit:

- Cloudflare API tokens
- Firebase Admin credentials
- Resend keys
- GitHub tokens / private keys
- signing keys
- internal service secrets
- owner access / refresh tokens

## Initial feature areas

- **Talk** — persistent owner conversation, voice and multimodal context
- **Pulse** — what needs attention now: health, incidents, crashes, releases and support
- **Activity** — what Next observed, investigated, changed, verified or is waiting on
- **Approvals** — sensitive actions awaiting owner authorization
- **Memory** — decisions, incidents, lessons and unresolved work
- **Connections** — GitHub, Cloudflare, Gmail/Resend, Firebase, Telegram and Otya service status
- **Device** — assistant role, wake experience, notifications, media and approved phone actions
- **Settings** — personality, voice, permissions, autonomy, interruption policy, privacy and security

## Migration rule

Existing AI/admin capabilities are not copied into the client. Their browser UI is retired; Otya Next is the sole owner experience. Privileged execution remains behind authenticated server APIs, with short-lived owner authorization, biometric step-up and explicit approval for high-impact actions.

See `docs/ARCHITECTURE.md`, `docs/MIGRATION_MAP.md`, and `docs/AI_EXECUTION_AND_EVALUATION_CONTRACT.md` for the AI execution, safety, hybrid operation, and evaluation gates.
