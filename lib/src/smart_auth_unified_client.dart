import 'dart:async';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:smart_auth_unified/src/biometrics/biometric_service.dart';
import 'package:smart_auth_unified/src/exceptions.dart';
import 'package:smart_auth_unified/src/models.dart';
import 'package:smart_auth_unified/src/observability/logger.dart';
import 'package:smart_auth_unified/src/offline/offline_queue.dart';
import 'package:smart_auth_unified/src/providers/base_provider.dart';
import 'package:smart_auth_unified/src/providers/email_password_provider.dart';
import 'package:smart_auth_unified/src/storage/token_storage.dart';

class SmartAuthClient {
  final Map<String, AuthProviderPlugin> _providers =
      <String, AuthProviderPlugin>{};
  final TokenStorage storage;
  final bool enableAesAtRest;
  final SmartAuthLogger logger;
  final BiometricService biometricService;
  final OfflineQueue offlineQueue;

  final StreamController<AuthSession?> _authStateController =
      StreamController<AuthSession?>.broadcast();

  static const String _sessionKey = 'smart_auth_unified:session';

  AuthSession? _currentSession;

  SmartAuthClient({
    required this.storage,
    this.enableAesAtRest = false,
    SmartAuthLogger? logger,
    BiometricService? biometricService,
    OfflineQueue? offlineQueue,
  }) : logger = logger ?? SmartAuthLogger(level: LogLevel.debug),
       biometricService = biometricService ?? BiometricService(),
       offlineQueue = offlineQueue ?? OfflineQueue();

  Stream<AuthSession?> get onAuthStateChanged => _authStateController.stream;

  AuthSession? get currentSession => _currentSession;

  bool hasRole(String role) => _currentSession?.roles.contains(role) ?? false;

  bool hasClaim(String key, Object value) =>
      _currentSession?.claims[key] == value;

  Future<void> registerProvider(AuthProviderPlugin provider) async {
    _providers[provider.id] = provider;
  }

  Future<void> unregisterProvider(String id) async {
    _providers.remove(id);
  }

  Future<void> initialize({bool requireBiometric = false}) async {
    logger.debug('Initializing SmartAuthClient');
    await _restoreSession(requireBiometric: requireBiometric);
  }

  Future<void> _restoreSession({bool requireBiometric = false}) async {
    try {
      final raw = await storage.read(_sessionKey);
      if (raw == null) return;
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final isJwt = map.containsKey('accessToken');
      final session = isJwt
          ? JwtSession.fromJson(map)
          : AuthSession.fromJson(map);
      if (requireBiometric) {
        final ok = await biometricService.authenticate(
          reason: 'Unlock your session',
        );
        if (!ok) return;
      }
      _setSession(session);
    } catch (e) {
      logger.warn('Failed to restore session: $e');
    }
  }

  Future<AuthSession> signIn({required AuthProvider provider}) async {
    final plugin = _pluginsByEnum(provider);
    final session = await plugin.signIn();
    await _persistSession(session);
    _setSession(session);
    return session;
  }

  Future<AuthSession> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    final plugin = _providers.values.firstWhereOrNull(
      (p) => p is EmailPasswordAuthProvider,
    );
    if (plugin is! EmailPasswordAuthProvider) {
      throw ProviderNotRegisteredException('email_password');
    }
    final session = await plugin.signInWithCredentials(email, password);
    await _persistSession(session);
    _setSession(session);
    return session;
  }

  Future<void> signOut({String? providerId}) async {
    final id = providerId ?? _currentSession?.providerId;
    if (id != null && _providers.containsKey(id)) {
      await _providers[id]!.signOut();
    }
    await storage.delete(_sessionKey);
    _setSession(null);
  }

  Future<AuthSession?> refresh() async {
    final session = _currentSession;
    if (session == null) return null;
    final provider = _providers[session.providerId];
    if (provider == null) return session;
    final refreshed = await provider.refresh(session);
    if (refreshed != null) {
      await _persistSession(refreshed);
      _setSession(refreshed);
      return refreshed;
    }
    return session;
  }

  Future<void> enqueueWhenOffline(Future<void> Function() task) async {
    offlineQueue.enqueue(task);
  }

  Future<void> replayOfflineQueue() => offlineQueue.replay();

  AuthProviderPlugin _pluginsByEnum(AuthProvider provider) {
    final id = _enumToId(provider);
    final plugin = _providers[id];
    if (plugin == null) {
      throw ProviderNotRegisteredException(id);
    }
    return plugin;
  }

  String _enumToId(AuthProvider provider) {
    switch (provider) {
      case AuthProvider.google:
        return 'google';
      case AuthProvider.emailPassword:
        return 'email_password';
      case AuthProvider.jwt:
        return 'jwt';
      case AuthProvider.apple:
        return 'apple';
      case AuthProvider.facebook:
        return 'facebook';
      case AuthProvider.github:
        return 'github';
      case AuthProvider.linkedin:
        return 'linkedin';
      case AuthProvider.twitter:
        return 'twitter';
      case AuthProvider.firebase:
        return 'firebase';
      case AuthProvider.supabase:
        return 'supabase';
      case AuthProvider.cognito:
        return 'cognito';
      case AuthProvider.oidc:
        return 'oidc';
      case AuthProvider.saml:
        return 'saml';
      case AuthProvider.ldap:
        return 'ldap';
    }
  }

  Future<void> _persistSession(AuthSession session) async {
    final json = jsonEncode(session.toJson());
    await storage.write(_sessionKey, json);
  }

  void _setSession(AuthSession? session) {
    _currentSession = session;
    _authStateController.add(session);
  }

  void dispose() {
    _authStateController.close();
  }
}
