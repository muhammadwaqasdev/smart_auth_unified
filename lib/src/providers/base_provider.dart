import 'package:smart_auth_unified/src/models.dart';

abstract class AuthProviderPlugin {
  String get id; // e.g., 'google', 'email_password', 'jwt'

  /// Start sign-in flow and return a session.
  Future<AuthSession> signIn();

  /// Sign out from provider.
  Future<void> signOut();

  /// Refresh a session if supported.
  Future<AuthSession?> refresh(AuthSession session) async => null;
}
