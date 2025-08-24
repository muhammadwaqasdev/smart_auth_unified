<h1 align="center">Smart Auth Unified</h1>

<p align="center">Unified authentication for Flutter/Dart with one simple API across many providers: Firebase, Supabase, Cognito, Auth0/Okta/Azure, Google, Apple, Facebook, Twitter/X, GitHub, LinkedIn, SAML, OIDC, LDAP, and custom JWT.</p><br>

<p align="center">
  <a href="https://flutter.dev">
    <img src="https://img.shields.io/badge/Platform-Flutter-02569B?logo=flutter"
      alt="Platform" />
  </a>
  <a href="https://pub.dartlang.org/packages/smart_auth_unified">
    <img src="https://img.shields.io/pub/v/smart_auth_unified.svg"
      alt="Pub Package" />
  </a>
  <a href="LICENSE">
    <img src="https://img.shields.io/github/license/muhammadwaqasdev/smart_auth_unified?color=red"
      alt="License: MIT" />
  </a>
  <a href="https://pub.dev/packages/smart_auth_unified/score">
    <img src="https://img.shields.io/pub/points/smart_auth_unified?label=Pub%20Points"
      alt="Pub Points" />
  </a>
  <a href="https://pub.dev/packages/smart_auth_unified/score">
    <img src="https://img.shields.io/pub/popularity/smart_auth_unified?label=Popularity"
      alt="Popularity" />
  </a>
  <a href="https://pub.dev/packages/smart_auth_unified/score">
    <img src="https://img.shields.io/pub/likes/smart_auth_unified?label=Pub%20Likes"
      alt="Pub Likes" />
  </a>
  <a href="https://pub.dev/packages/smart_auth_unified">
    <img src="https://img.shields.io/badge/Dart%20SDK-%3E%3D3.8-blue?logo=dart"
      alt="Dart SDK >= 3.8" />
  </a>
</p><br>

## Table of contents

- [Getting started](#getting-started)
  - [Install](#install)
  - [Production checklist](#production-checklist)
  - [Quick start](#quick-start)
- [Core concepts](#core-concepts)
  - [Unified API](#unified-api)
  - [Features](#features)
- [Provider matrix](#provider-matrix)
- [Provider guides](#provider-guides)
  - [Google Android](#google-android) | [Google iOS](#google-ios) | [Google Use](#google-use)
  - [Apple iOS](#apple-ios) | [Apple Use](#apple-use)
  - [Facebook Android](#facebook-android) | [Facebook iOS](#facebook-ios) | [Facebook Use](#facebook-use)
  - [GitHub Console](#github-console) | [GitHub App setup](#github-app-setup) | [GitHub Use](#github-use)
  - [LinkedIn Console](#linkedin-console) | [LinkedIn App setup](#linkedin-app-setup) | [LinkedIn Use](#linkedin-use)
  - [Twitter Console](#twitter-console) | [Twitter App setup](#twitter-app-setup) | [Twitter Use](#twitter-use)
  - [Firebase Enable providers](#firebase-enable-providers) | [Firebase Use](#firebase-use)
  - [Supabase Enable providers](#supabase-enable-providers) | [Supabase Use](#supabase-use)
  - [Cognito Console](#cognito-console) | [Cognito Use](#cognito-use)
  - [OIDC Console](#oidc-console) | [OIDC Use](#oidc-use)
  - [SAML Backend](#saml-backend) | [SAML Use](#saml-use)
  - [LDAP Backend](#ldap-backend) | [LDAP Use](#ldap-use)
- [Example app](#example-app)
- [License](#license)

## Getting started

### Install

Add to `pubspec.yaml`:

```yaml
dependencies:
  smart_auth_unified: ^0.0.1
```

Then run `flutter pub get`.

### Production checklist

- Configure platform setup for providers (Android/iOS/Web)
- Use `SecureTokenStorage.defaultInstance(aesKey: '32-char-secret')` for AES-at-rest
- Gate sensitive flows with biometrics where possible
- For Firebase/Supabase, sign in with their SDKs, then mirror the session via adapters

### Quick start

```dart
import 'package:smart_auth_unified/smart_auth_unified.dart';

void main() async {
  final auth = SmartAuthClient(
    storage: SecureTokenStorage.defaultInstance(),
  );

  await auth.registerProvider(GoogleAuthProvider());
  await auth.registerProvider(
    EmailPasswordAuthProvider(signInCallback: (email, password) async {
      // Call your backend and return a JwtSession
      return JwtSession(
        providerId: 'jwt',
        accessToken: 'token',
        refreshToken: 'refresh',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
        user: const AuthUser(id: '1', email: 'you@example.com'),
        roles: const {'user'},
        claims: const {'tenant': 'acme'},
      );
    }),
  );

  final session = await auth.signIn(provider: AuthProvider.google);
  print('Signed in as: ${session.user.email}');
}
```

## Core concepts

### Unified API

- `auth.signIn(provider: AuthProvider.google)`
- `auth.signOut()`
- `auth.currentSession`
- `auth.onAuthStateChanged` (stream)
- `auth.hasRole('admin')`, `auth.hasClaim('tenant', 'acme')`

### Features

- Unified API via pluggable providers
- Secure token storage; optional AES encryption at rest
- Sessions: auto-restore, refresh, stream, multi-provider registry
- Offline-first: cached sessions and queued actions to replay
- Roles & claims helpers
- Biometric unlock (Face ID / Touch ID / PIN)
- Cross-platform: iOS, Android, Web (limited), Desktop, backend Dart
- Observability: debug logs and hooks

## Provider matrix

| Provider | Package | Status |
|---|---|---|
| Google | `google_sign_in` | Implemented |
| Email/Password | custom | Implemented |
| JWT (custom backend) | custom | Implemented |
| Apple | `sign_in_with_apple` | Implemented |
| Facebook | `flutter_facebook_auth` | Implemented |
| GitHub | OAuth (web) | Implemented |
| LinkedIn | OAuth (web) | Implemented |
| Twitter/X | `twitter_login` | Implemented |
| Firebase | `firebase_auth` | Implemented (adapter) |
| Supabase | `supabase_flutter` | Implemented (adapter) |
| Cognito | `flutter_appauth` | Implemented (OIDC) |
| OIDC (generic) | `flutter_appauth` | Implemented |
| SAML | `flutter_web_auth_2` (backend ACS) | Implemented |
| LDAP | custom backend | Implemented |

## General platform setup

- Android: add OAuth redirect intent filters; register SHA-1/SHA-256 where needed
- iOS: add URL schemes/capabilities; associated domains if required
- Web: authorize redirect URLs in provider consoles

## Provider guides

Quick index:

- Google: [Android](#google-android) | [iOS](#google-ios) | [Use](#google-use)
- Apple: [iOS](#apple-ios) | [Use](#apple-use)
- Facebook: [Android](#facebook-android) | [iOS](#facebook-ios) | [Use](#facebook-use)
- GitHub: [Console](#github-console) | [App setup](#github-app-setup) | [Use](#github-use)
- LinkedIn: [Console](#linkedin-console) | [App setup](#linkedin-app-setup) | [Use](#linkedin-use)
- Twitter/X: [Console](#twitter-console) | [App setup](#twitter-app-setup) | [Use](#twitter-use)
- Firebase adapter: [Enable providers](#firebase-enable-providers) | [Use](#firebase-use)
- Supabase adapter: [Enable providers](#supabase-enable-providers) | [Use](#supabase-use)
- Cognito: [Console](#cognito-console) | [Use](#cognito-use)
- OIDC: [Console](#oidc-console) | [Use](#oidc-use)
- SAML: [Backend](#saml-backend) | [Use](#saml-use)
- LDAP: [Backend](#ldap-backend) | [Use](#ldap-use)

### Google

#### Android
- Create OAuth client in Google Cloud for Android
- Add SHA-1/SHA-256 fingerprints

#### iOS
- Create iOS OAuth client; add reversed client ID in URL Schemes

Info.plist (URL Types) example:
```xml
<key>CFBundleURLTypes</key>
<array>
<dict>
  <key>CFBundleURLSchemes</key>
  <array>
    <string>com.googleusercontent.apps.YOUR_REVERSED_CLIENT_ID</string>
  </array>
</dict>
</array>
```

#### Use
```dart
await auth.registerProvider(GoogleAuthProvider());
final session = await auth.signIn(provider: AuthProvider.google);
```

### Apple

#### iOS
- Enable “Sign in with Apple” capability in target settings

#### Use
```dart
await auth.registerProvider(AppleAuthProvider());
final session = await auth.signIn(provider: AuthProvider.apple);
```

### Facebook

#### Android
`android/app/src/main/res/values/strings.xml`
```xml
<resources>
  <string name="facebook_app_id">YOUR_FACEBOOK_APP_ID</string>
  <string name="fb_login_protocol_scheme">fbYOUR_FACEBOOK_APP_ID</string>
</resources>
```

AndroidManifest (application):
```xml
<meta-data android:name="com.facebook.sdk.ApplicationId" android:value="@string/facebook_app_id" />
<activity android:name="com.facebook.FacebookActivity" android:configChanges="keyboard|keyboardHidden|screenLayout|screenSize|orientation" />
<provider android:authorities="com.facebook.app.FacebookContentProvider${applicationId}" android:name="com.facebook.FacebookContentProvider" android:exported="true" />
```

#### iOS
Info.plist:
```xml
<key>CFBundleURLTypes</key>
<array>
<dict>
  <key>CFBundleURLSchemes</key>
  <array>
    <string>fbYOUR_FACEBOOK_APP_ID</string>
  </array>
</dict>
</array>
<key>LSApplicationQueriesSchemes</key>
<array>
<string>fbapi</string>
<string>fb-messenger-share-api</string>
<string>fbauth2</string>
</array>
```

#### Use
```dart
await auth.registerProvider(FacebookAuthProvider());
final session = await auth.signIn(provider: AuthProvider.facebook);
```

### GitHub (OAuth via web)

#### Console
- Create an OAuth App and set callback to `your.app://callback`

#### App setup
- iOS: add `your.app` scheme in URL Types
- Android: add intent filter if needed

#### Use
```dart
await auth.registerProvider(GitHubAuthProvider(
clientId: 'GITHUB_CLIENT_ID',
clientSecret: 'GITHUB_CLIENT_SECRET',
redirectUri: 'your.app://callback',
));
final session = await auth.signIn(provider: AuthProvider.github);
```

### LinkedIn (OAuth via web)

#### Console
- Create app; set redirect URI

#### App setup
- Add URL scheme for your redirect

#### Use
```dart
await auth.registerProvider(LinkedInAuthProvider(
clientId: 'LINKEDIN_CLIENT_ID',
clientSecret: 'LINKEDIN_CLIENT_SECRET',
redirectUri: 'your.app://callback',
));
final session = await auth.signIn(provider: AuthProvider.linkedin);
```

### Twitter/X

#### Console
- Create developer app; set callback to `your.app://callback`

#### App setup
- iOS URL scheme; Android intent filter if needed

#### Use
```dart
await auth.registerProvider(TwitterAuthProvider(
apiKey: 'TWITTER_API_KEY',
apiSecretKey: 'TWITTER_API_SECRET',
redirectUri: 'your.app://callback',
));
final session = await auth.signIn(provider: AuthProvider.twitter);
```

### Firebase (adapter; dynamic)

#### Enable providers
- In Firebase Console, enable Google/Apple/GitHub/Twitter/etc.
- Use `firebase_auth` (and provider plugins/FirebaseUI) for sign-in

#### Use
```dart
await auth.registerProvider(FirebaseAuthProvider());
final session = await auth.signIn(provider: AuthProvider.firebase);
```

### Supabase (adapter; dynamic)

#### Enable providers
- In Supabase Dashboard, enable providers and configure redirect URL

#### Use
```dart
await auth.registerProvider(SupabaseAuthProvider());
final session = await auth.signIn(provider: AuthProvider.supabase);
```

### Cognito (OIDC via AppAuth)

#### Console
- Create a User Pool app client (no secret); set hosted UI domain and redirect URL

#### Use
```dart
await auth.registerProvider(CognitoAuthProvider(
clientId: 'COGNITO_CLIENT_ID',
redirectUrl: 'your.app://callback',
discoveryUrl: 'https://your-domain/.well-known/openid-configuration',
));
final session = await auth.signIn(provider: AuthProvider.cognito);
await auth.refresh();
```

### OIDC (Auth0/Okta/Azure AD/Keycloak)

#### Console
- Create native app; set redirect URI `your.app://callback`; copy discovery URL

#### Use
```dart
await auth.registerProvider(OidcAuthProvider(
clientId: 'OIDC_CLIENT_ID',
redirectUrl: 'your.app://callback',
discoveryUrl: 'https://issuer/.well-known/openid-configuration',
));
final session = await auth.signIn(provider: AuthProvider.oidc);
```

### SAML (backend ACS)

#### Backend
- Implement SAML initiation and ACS on your server; redirect back to app scheme with token

#### Use
```dart
await auth.registerProvider(SamlAuthProvider(
authUrl: 'https://your-backend.example.com/auth/saml/start',
callbackScheme: 'your.app',
));
final session = await auth.signIn(provider: AuthProvider.saml);
```

### LDAP (backend)

#### Backend
- Expose an endpoint to bind/authe
- nticate and issue JWT

#### Use
```dart
await auth.registerProvider(LdapAuthProvider(signInCallback: (username, password) async {
// call your backend and return a JwtSession
throw UnimplementedError();
}));
```

## Example app

See `example/` for a Flutter demo covering email/password, Google Sign-In, role checks, and biometric unlock.

## License

MIT — see `LICENSE`.
