import 'package:smart_auth_unified/src/models.dart';
import 'package:smart_auth_unified/src/providers/base_provider.dart';

/// A lightweight email/password provider backed by a user-supplied callback
/// that performs the real authentication (e.g. via a REST API) and returns
/// a [JwtSession].
class EmailPasswordAuthProvider extends AuthProviderPlugin {
  final Future<JwtSession> Function(String email, String password)
  signInCallback;

  EmailPasswordAuthProvider({required this.signInCallback});

  @override
  String get id => 'email_password';

  @override
  Future<AuthSession> signIn() async {
    throw UnsupportedError('Use signInWithCredentials(email, password)');
  }

  Future<AuthSession> signInWithCredentials(String email, String password) {
    return signInCallback(email, password);
  }

  @override
  Future<void> signOut() async {}
}
