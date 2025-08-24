import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:smart_auth_unified/src/models.dart';
import 'package:smart_auth_unified/src/providers/base_provider.dart';

class OidcAuthProvider extends AuthProviderPlugin {
  final String clientId;
  final String redirectUrl;
  final String discoveryUrl;
  final List<String> scopes;
  final FlutterAppAuth _appAuth = const FlutterAppAuth();

  OidcAuthProvider({
    required this.clientId,
    required this.redirectUrl,
    required this.discoveryUrl,
    this.scopes = const ['openid', 'profile', 'email', 'offline_access'],
  });

  @override
  String get id => 'oidc';

  @override
  Future<AuthSession> signIn() async {
    final TokenResponse? result = await _appAuth.authorizeAndExchangeCode(
      AuthorizationTokenRequest(
        clientId,
        redirectUrl,
        discoveryUrl: discoveryUrl,
        scopes: scopes,
      ),
    );
    if (result == null) throw Exception('OIDC sign-in failed');
    const user = AuthUser(id: 'oidc');
    return JwtSession(
      providerId: id,
      user: user,
      accessToken: result.accessToken ?? '',
      refreshToken: result.refreshToken,
      expiresAt: result.accessTokenExpirationDateTime,
    );
  }

  @override
  Future<AuthSession?> refresh(AuthSession session) async {
    if (session is! JwtSession || session.refreshToken == null) return null;
    final TokenResponse? result = await _appAuth.token(
      TokenRequest(
        clientId,
        redirectUrl,
        discoveryUrl: discoveryUrl,
        refreshToken: session.refreshToken,
        scopes: scopes,
      ),
    );
    if (result == null) return null;
    return JwtSession(
      providerId: id,
      user: session.user,
      accessToken: result.accessToken ?? session.accessToken,
      refreshToken: result.refreshToken ?? session.refreshToken,
      expiresAt: result.accessTokenExpirationDateTime ?? session.expiresAt,
      roles: session.roles,
      claims: session.claims,
    );
  }

  @override
  Future<void> signOut() async {}
}
