import 'package:firebase_auth/firebase_auth.dart' as fba;
import 'package:smart_auth_unified/src/models.dart';
import 'package:smart_auth_unified/src/providers/base_provider.dart';

class FirebaseAuthProvider extends AuthProviderPlugin {
  final fba.FirebaseAuth _auth;

  FirebaseAuthProvider({fba.FirebaseAuth? auth})
    : _auth = auth ?? fba.FirebaseAuth.instance;

  @override
  String get id => 'firebase';

  @override
  Future<AuthSession> signIn() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception(
        'Call signInWithCredential via Firebase before using this adapter',
      );
    }
    final token = await user.getIdToken() ?? '';
    return JwtSession(
      providerId: id,
      user: AuthUser(
        id: user.uid,
        email: user.email,
        displayName: user.displayName,
        avatarUrl: user.photoURL,
      ),
      accessToken: token,
      expiresAt: DateTime.now().add(const Duration(minutes: 55)),
    );
  }

  @override
  Future<void> signOut() => _auth.signOut();
}
