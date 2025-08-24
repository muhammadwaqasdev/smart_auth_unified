import 'package:flutter_test/flutter_test.dart';
import 'package:smart_auth_unified/smart_auth_unified.dart';

void main() {
  test('Auth session serialize/deserialize', () {
    const user = AuthUser(id: 'u1', email: 'a@b.com');
    final session = JwtSession(
      providerId: 'jwt',
      user: user,
      accessToken: 'token',
      refreshToken: 'refresh',
      expiresAt: DateTime.now().add(const Duration(minutes: 5)),
      roles: const {'admin'},
      claims: const {'tenant': 'acme'},
    );
    final json = session.toJson();
    final roundtrip = JwtSession.fromJson(json);
    expect(roundtrip.user.email, 'a@b.com');
    expect(roundtrip.roles.contains('admin'), true);
  });
}
