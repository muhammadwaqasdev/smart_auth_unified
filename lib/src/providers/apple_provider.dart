import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:smart_auth_unified/src/models.dart';
import 'package:smart_auth_unified/src/providers/base_provider.dart';

class AppleAuthProvider extends AuthProviderPlugin {
  @override
  String get id => 'apple';

  @override
  Future<AuthSession> signIn() async {
    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    final user = AuthUser(
      id: credential.userIdentifier ?? 'apple-user',
      email: credential.email,
      displayName: credential.givenName != null || credential.familyName != null
          ? '${credential.givenName ?? ''} ${credential.familyName ?? ''}'
                .trim()
          : null,
    );

    return JwtSession(
      providerId: id,
      user: user,
      accessToken: credential.identityToken ?? '',
      refreshToken: credential.authorizationCode,
      expiresAt: DateTime.now().add(const Duration(hours: 1)),
    );
  }

  @override
  Future<void> signOut() async {}
}
