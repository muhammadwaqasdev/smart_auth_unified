import 'package:smart_auth_unified/src/models.dart';
import 'package:smart_auth_unified/src/providers/base_provider.dart';
import 'package:twitter_login/twitter_login.dart';

class TwitterAuthProvider extends AuthProviderPlugin {
  final String apiKey;
  final String apiSecretKey;
  final String redirectUri;

  TwitterAuthProvider({
    required this.apiKey,
    required this.apiSecretKey,
    required this.redirectUri,
  });

  @override
  String get id => 'twitter';

  @override
  Future<AuthSession> signIn() async {
    final twitterLogin = TwitterLogin(
      apiKey: apiKey,
      apiSecretKey: apiSecretKey,
      redirectURI: redirectUri,
    );
    final authResult = await twitterLogin.login();
    if (authResult.status != TwitterLoginStatus.loggedIn) {
      throw Exception('Twitter sign-in failed: ${authResult.status}');
    }
    final user = AuthUser(
      id: authResult.user!.id.toString(),
      displayName: authResult.user!.name,
      avatarUrl: authResult.user!.thumbnailImage,
    );
    return JwtSession(
      providerId: id,
      user: user,
      accessToken: authResult.authToken!,
      refreshToken: authResult.authTokenSecret,
      expiresAt: DateTime.now().add(const Duration(hours: 1)),
    );
  }

  @override
  Future<void> signOut() async {}
}
