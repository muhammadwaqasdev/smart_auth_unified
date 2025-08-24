import 'dart:convert';

import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:http/http.dart' as http;
import 'package:smart_auth_unified/src/models.dart';
import 'package:smart_auth_unified/src/providers/base_provider.dart';

class GitHubAuthProvider extends AuthProviderPlugin {
  final String clientId;
  final String clientSecret;
  final String redirectUri;
  final List<String> scopes;

  GitHubAuthProvider({
    required this.clientId,
    required this.clientSecret,
    required this.redirectUri,
    this.scopes = const ['read:user', 'user:email'],
  });

  @override
  String get id => 'github';

  @override
  Future<AuthSession> signIn() async {
    final authUrl = Uri.https('github.com', '/login/oauth/authorize', {
      'client_id': clientId,
      'redirect_uri': redirectUri,
      'scope': scopes.join(' '),
      'allow_signup': 'true',
    });
    final result = await FlutterWebAuth2.authenticate(
      url: authUrl.toString(),
      callbackUrlScheme: Uri.parse(redirectUri).scheme,
    );
    final code = Uri.parse(result).queryParameters['code'];
    if (code == null) {
      throw Exception('GitHub OAuth flow did not return code');
    }
    final tokenRes = await http.post(
      Uri.https('github.com', '/login/oauth/access_token'),
      headers: {'Accept': 'application/json'},
      body: {
        'client_id': clientId,
        'client_secret': clientSecret,
        'code': code,
        'redirect_uri': redirectUri,
      },
    );
    final tokenBody = jsonDecode(tokenRes.body) as Map<String, dynamic>;
    final accessToken = tokenBody['access_token'] as String;

    final userRes = await http.get(
      Uri.https('api.github.com', '/user'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Accept': 'application/json',
      },
    );
    final userJson = jsonDecode(userRes.body) as Map<String, dynamic>;

    final emailsRes = await http.get(
      Uri.https('api.github.com', '/user/emails'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Accept': 'application/json',
      },
    );
    final emails = (jsonDecode(emailsRes.body) as List<dynamic>?) ?? [];
    final primaryEmail =
        emails.cast<Map<String, dynamic>?>().firstWhere(
              (e) => e?['primary'] == true,
              orElse: () => null,
            )?['email']
            as String?;

    final user = AuthUser(
      id: userJson['id'].toString(),
      email: primaryEmail,
      displayName: userJson['name'] as String? ?? userJson['login'] as String?,
      avatarUrl: userJson['avatar_url'] as String?,
    );

    return JwtSession(
      providerId: id,
      user: user,
      accessToken: accessToken,
      expiresAt: DateTime.now().add(const Duration(hours: 8)),
    );
  }

  @override
  Future<void> signOut() async {}
}
