import 'dart:convert';

import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:http/http.dart' as http;
import 'package:smart_auth_unified/src/models.dart';
import 'package:smart_auth_unified/src/providers/base_provider.dart';

class LinkedInAuthProvider extends AuthProviderPlugin {
  final String clientId;
  final String clientSecret;
  final String redirectUri;
  final List<String> scopes;

  LinkedInAuthProvider({
    required this.clientId,
    required this.clientSecret,
    required this.redirectUri,
    this.scopes = const ['r_liteprofile', 'r_emailaddress'],
  });

  @override
  String get id => 'linkedin';

  @override
  Future<AuthSession> signIn() async {
    final authUrl = Uri.https('www.linkedin.com', '/oauth/v2/authorization', {
      'response_type': 'code',
      'client_id': clientId,
      'redirect_uri': redirectUri,
      'scope': scopes.join(' '),
      'state': 'smart_auth',
    });
    final result = await FlutterWebAuth2.authenticate(
      url: authUrl.toString(),
      callbackUrlScheme: Uri.parse(redirectUri).scheme,
    );
    final code = Uri.parse(result).queryParameters['code'];
    if (code == null) throw Exception('LinkedIn OAuth did not return code');

    final tokenRes = await http.post(
      Uri.https('www.linkedin.com', '/oauth/v2/accessToken'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'grant_type': 'authorization_code',
        'code': code,
        'redirect_uri': redirectUri,
        'client_id': clientId,
        'client_secret': clientSecret,
      },
    );
    final tokenBody = jsonDecode(tokenRes.body) as Map<String, dynamic>;
    final accessToken = tokenBody['access_token'] as String;

    final meRes = await http.get(
      Uri.https('api.linkedin.com', '/v2/me'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );
    final me = jsonDecode(meRes.body) as Map<String, dynamic>;
    final emailRes = await http.get(
      Uri.https('api.linkedin.com', '/v2/emailAddress', {
        'q': 'members',
        'projection': '(elements*(handle~))',
      }),
      headers: {'Authorization': 'Bearer $accessToken'},
    );
    final email =
        (((jsonDecode(emailRes.body) as Map)['elements'] as List).first
                as Map)['handle~']['emailAddress']
            as String?;

    final user = AuthUser(
      id: me['id'] as String,
      email: email,
      displayName:
          ('${me['localizedFirstName'] ?? ''} ${me['localizedLastName'] ?? ''}')
              .trim(),
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
