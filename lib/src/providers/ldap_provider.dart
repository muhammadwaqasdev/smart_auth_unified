import 'package:smart_auth_unified/src/models.dart';
import 'package:smart_auth_unified/src/providers/base_provider.dart';

/// LDAP typically requires backend mediation. This provider assumes your backend
/// exposes an endpoint that performs LDAP bind and returns a JWT session.
class LdapAuthProvider extends AuthProviderPlugin {
  final Future<JwtSession> Function(String username, String password)
  signInCallback;

  LdapAuthProvider({required this.signInCallback});

  @override
  String get id => 'ldap';

  @override
  Future<AuthSession> signIn() {
    throw UnsupportedError('Use signInWithCredentials(username, password)');
  }

  Future<AuthSession> signInWithCredentials(String username, String password) =>
      signInCallback(username, password);

  @override
  Future<void> signOut() async {}
}
