import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:smart_auth_unified/src/models.dart';
import 'package:smart_auth_unified/src/providers/base_provider.dart';

/// Minimal SAML flow via web redirect to your IdP and backend ACS.
/// The actual SAML handshake occurs on your backend. This provider captures
/// the final callback with a session token produced by your backend.
class SamlAuthProvider extends AuthProviderPlugin {
  final String authUrl;
  final String callbackScheme;

  SamlAuthProvider({required this.authUrl, required this.callbackScheme});

  @override
  String get id => 'saml';

  @override
  Future<AuthSession> signIn() async {
    final result = await FlutterWebAuth2.authenticate(
      url: authUrl,
      callbackUrlScheme: callbackScheme,
    );
    final uri = Uri.parse(result);
    final token = uri.queryParameters['token'].toString().isNotEmpty
        ? uri.queryParameters['token']
        : (uri.fragment.isNotEmpty ? uri.fragment : null);
    if (token == null) throw Exception('SAML flow did not return token');
    const user = AuthUser(id: 'saml');
    return JwtSession(
      providerId: id,
      user: user,
      accessToken: token,
      expiresAt: DateTime.now().add(const Duration(hours: 8)),
    );
  }

  @override
  Future<void> signOut() async {}
}
