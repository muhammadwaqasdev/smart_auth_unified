import 'package:smart_auth_unified/src/models.dart';
import 'package:smart_auth_unified/src/providers/base_provider.dart';

/// A minimal provider that accepts an existing JWT session (e.g., when your
/// backend authenticates via custom flows) and simply returns it.
class JwtAuthProvider extends AuthProviderPlugin {
  final JwtSession Function() getSession;

  JwtAuthProvider({required this.getSession});

  @override
  String get id => 'jwt';

  @override
  Future<AuthSession> signIn() async => getSession();

  @override
  Future<void> signOut() async {}
}
