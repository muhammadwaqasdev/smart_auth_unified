import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:smart_auth_unified/src/models.dart';
import 'package:smart_auth_unified/src/providers/base_provider.dart';

class FacebookAuthProvider extends AuthProviderPlugin {
  @override
  String get id => 'facebook';

  @override
  Future<AuthSession> signIn() async {
    final result = await FacebookAuth.instance.login(
      permissions: ['email', 'public_profile'],
    );
    if (result.status != LoginStatus.success) {
      throw Exception('Facebook sign-in failed: ${result.status}');
    }
    final data = await FacebookAuth.instance.getUserData(
      fields: 'id,name,email,picture.width(200)',
    );
    final user = AuthUser(
      id: data['id'] as String,
      email: data['email'] as String?,
      displayName: data['name'] as String?,
      avatarUrl: ((data['picture'] as Map)['data'] as Map)['url'] as String?,
    );
    final accessToken = result.accessToken?.tokenString ?? '';
    return JwtSession(
      providerId: id,
      user: user,
      accessToken: accessToken,
      expiresAt: DateTime.now().add(const Duration(hours: 8)),
    );
  }

  @override
  Future<void> signOut() async {
    await FacebookAuth.instance.logOut();
  }
}
