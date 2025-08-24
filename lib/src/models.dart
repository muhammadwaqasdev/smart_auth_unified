import 'package:meta/meta.dart';

/// Enum of built-in providers. Extend via plugins for more providers.
enum AuthProvider {
  google,
  emailPassword,
  jwt,
  apple,
  facebook,
  github,
  linkedin,
  twitter,
  firebase,
  supabase,
  cognito,
  oidc,
  saml,
  ldap,
}

@immutable
class AuthUser {
  final String id;
  final String? email;
  final String? displayName;
  final String? avatarUrl;

  const AuthUser({
    required this.id,
    this.email,
    this.displayName,
    this.avatarUrl,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'displayName': displayName,
    'avatarUrl': avatarUrl,
  };

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
    id: json['id'] as String,
    email: json['email'] as String?,
    displayName: json['displayName'] as String?,
    avatarUrl: json['avatarUrl'] as String?,
  );
}

/// Represents an authenticated session. Use [JwtSession] for token-based auth.
@immutable
class AuthSession {
  final String providerId;
  final AuthUser user;
  final Set<String> roles;
  final Map<String, dynamic> claims;
  final DateTime? expiresAt;

  const AuthSession({
    required this.providerId,
    required this.user,
    this.roles = const <String>{},
    this.claims = const <String, dynamic>{},
    this.expiresAt,
  });

  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);

  Map<String, dynamic> toJson() => {
    'providerId': providerId,
    'user': user.toJson(),
    'roles': roles.toList(),
    'claims': claims,
    'expiresAt': expiresAt?.toIso8601String(),
  };

  factory AuthSession.fromJson(Map<String, dynamic> json) => AuthSession(
    providerId: json['providerId'] as String,
    user: AuthUser.fromJson(json['user'] as Map<String, dynamic>),
    roles: (json['roles'] as List<dynamic>? ?? const <dynamic>[])
        .map((e) => e.toString())
        .toSet(),
    claims: (json['claims'] as Map<String, dynamic>? ?? <String, dynamic>{}),
    expiresAt: (json['expiresAt'] as String?) != null
        ? DateTime.parse(json['expiresAt'] as String)
        : null,
  );
}

/// JWT or OAuth2 style session with tokens.
@immutable
class JwtSession extends AuthSession {
  final String accessToken;
  final String? refreshToken;

  const JwtSession({
    required super.providerId,
    required super.user,
    required this.accessToken,
    this.refreshToken,
    super.roles = const <String>{},
    super.claims = const <String, dynamic>{},
    super.expiresAt,
  });

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'accessToken': accessToken,
    'refreshToken': refreshToken,
  };

  factory JwtSession.fromJson(Map<String, dynamic> json) => JwtSession(
    providerId: json['providerId'] as String,
    user: AuthUser.fromJson(json['user'] as Map<String, dynamic>),
    accessToken: json['accessToken'] as String,
    refreshToken: json['refreshToken'] as String?,
    roles: (json['roles'] as List<dynamic>? ?? const <dynamic>[])
        .map((e) => e.toString())
        .toSet(),
    claims: (json['claims'] as Map<String, dynamic>? ?? <String, dynamic>{}),
    expiresAt: (json['expiresAt'] as String?) != null
        ? DateTime.parse(json['expiresAt'] as String)
        : null,
  );
}
