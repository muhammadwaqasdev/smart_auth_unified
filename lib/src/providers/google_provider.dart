import 'package:google_sign_in/google_sign_in.dart';
import 'package:smart_auth_unified/src/models.dart';
import 'package:smart_auth_unified/src/providers/base_provider.dart';

class GoogleAuthProvider extends AuthProviderPlugin {
  final GoogleSignIn _googleSignIn;

  GoogleAuthProvider({GoogleSignIn? googleSignIn})
    : _googleSignIn =
          googleSignIn ?? GoogleSignIn(scopes: const ['email', 'profile']);

  @override
  String get id => 'google';

  @override
  Future<AuthSession> signIn() async {
    final account = await _googleSignIn.signIn();
    if (account == null) {
      throw Exception('Google sign-in aborted');
    }
    final auth = await account.authentication;
    final user = AuthUser(
      id: account.id,
      email: account.email,
      displayName: account.displayName,
      avatarUrl: account.photoUrl,
    );
    return JwtSession(
      providerId: id,
      user: user,
      accessToken: auth.accessToken ?? '',
      refreshToken: auth.idToken, // not a real refresh token; placeholder
      expiresAt: DateTime.now().add(const Duration(hours: 1)),
    );
  }

  @override
  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }
}
