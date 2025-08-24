## 0.0.1 - Initial Release

- 🚀 First release of **smart_auth_unified**.
- Unified authentication API for multiple providers (Google, Apple, Facebook, GitHub, LinkedIn, Firebase, Supabase, AWS Cognito, Auth0, OIDC, SAML, LDAP, custom JWT).
- 🔑 Token management with secure storage and optional AES encryption.
- 🔄 Session handling: auto-restore, multi-account, `onAuthStateChanged` streams.
- 📡 Offline-first authentication with cached sessions and queued actions.
- 👥 Role & claims management via `auth.hasRole("admin")`.
- 🔐 Biometric & local authentication integration (Face ID, Touch ID, PIN fallback).
- 🌐 Cross-platform support: Flutter (mobile/web) and pure Dart (backend).
- 📊 Observability: debug logs & metrics for login/logout events.
- 📦 Example Flutter app included with:
    - Email/password login
    - Google sign-in
    - Role check
    - Biometric unlock