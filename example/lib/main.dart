import 'dart:async' show StreamSubscription;

import 'package:flutter/material.dart';
import 'package:smart_auth_unified/smart_auth_unified.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'smart_auth_unified demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      home: const DemoPage(),
    );
  }
}

class DemoPage extends StatefulWidget {
  const DemoPage({super.key});

  @override
  State<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> {
  late final SmartAuthClient auth;
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  StreamSubscription<AuthSession?>? sub;
  AuthSession? session;

  @override
  void initState() {
    super.initState();
    auth = SmartAuthClient(storage: SecureTokenStorage.defaultInstance());
    auth.registerProvider(GoogleAuthProvider());
    auth.registerProvider(
      EmailPasswordAuthProvider(
        signInCallback: (e, p) async {
          // This is just a demo. Replace with your backend call.
          return JwtSession(
            providerId: 'jwt',
            accessToken: 'demo-token',
            refreshToken: 'demo-refresh',
            expiresAt: DateTime.now().add(const Duration(minutes: 30)),
            user: AuthUser(id: 'demo', email: e),
            roles: const {'user'},
            claims: const {'tenant': 'demo'},
          );
        },
      ),
    );
    auth.initialize();
    sub = auth.onAuthStateChanged.listen((s) => setState(() => session = s));
  }

  @override
  void dispose() {
    sub?.cancel();
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> _biometricUnlock() async {
    final ok = await auth.biometricService.authenticate(
      reason: 'Unlock your session',
    );
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(ok ? 'Unlocked' : 'Failed')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('smart_auth_unified demo')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Status: ${session == null ? 'Signed out' : 'Signed in as ${session!.user.email ?? session!.user.id}'}',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: email,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: password,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    await auth.signInWithEmailPassword(
                      email.text,
                      password.text,
                    );
                  },
                  child: const Text('Email/Password Login'),
                ),
                OutlinedButton(
                  onPressed: () async {
                    await auth.signIn(provider: AuthProvider.google);
                  },
                  child: const Text('Google Sign-In'),
                ),
                OutlinedButton(
                  onPressed: session != null && auth.hasRole('admin')
                      ? null
                      : () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Admin role required'),
                            ),
                          );
                        },
                  child: const Text('Check Admin Role'),
                ),
                OutlinedButton(
                  onPressed: _biometricUnlock,
                  child: const Text('Biometric Unlock'),
                ),
                TextButton(
                  onPressed: () => auth.signOut(),
                  child: const Text('Sign out'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
