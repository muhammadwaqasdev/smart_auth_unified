import 'package:supabase_flutter/supabase_flutter.dart' hide AuthUser;
import 'package:smart_auth_unified/src/models.dart'
    show AuthUser, JwtSession, AuthSession;
import 'package:smart_auth_unified/src/providers/base_provider.dart';

class SupabaseAuthProvider extends AuthProviderPlugin {
  final SupabaseClient client;

  SupabaseAuthProvider({SupabaseClient? client})
    : client = client ?? Supabase.instance.client;

  @override
  String get id => 'supabase';

  @override
  Future<AuthSession> signIn() async {
    final session = client.auth.currentSession;
    final user = client.auth.currentUser;
    if (session == null || user == null) {
      throw Exception('Call Supabase signIn* first then use this adapter');
    }
    return JwtSession(
      providerId: id,
      user: AuthUser(id: user.id, email: user.email),
      accessToken: session.accessToken,
      refreshToken: session.refreshToken,
      expiresAt: session.expiresAt != null
          ? DateTime.fromMillisecondsSinceEpoch(session.expiresAt! * 1000)
          : null,
    );
  }

  @override
  Future<void> signOut() async {
    await client.auth.signOut();
  }
}
