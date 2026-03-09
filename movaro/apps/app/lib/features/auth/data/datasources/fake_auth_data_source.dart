import 'dart:async';

import 'package:movaro_app/core/environment/app_environment.dart';
import 'package:movaro_app/core/environment/app_flavor.dart';
import 'package:movaro_app/features/auth/data/datasources/auth_data_source.dart';
import 'package:movaro_app/features/auth/domain/entities/auth_provider.dart';
import 'package:movaro_app/features/auth/domain/entities/auth_session.dart';

class FakeAuthDataSource implements AuthDataSource {
  FakeAuthDataSource({required AppEnvironment environment})
    : _environment = environment;

  final AppEnvironment _environment;
  AuthSession _session = const AuthSession.guest();

  bool get _isDevelopment => _environment.flavor == AppFlavor.development;

  @override
  Future<AuthSession> restoreSession() async {
    return _session;
  }

  @override
  Future<AuthSession> signIn(AuthProvider provider) async {
    if (!_isDevelopment) {
      throw StateError(
        'FakeAuthDataSource is available only in development builds.',
      );
    }

    _session = AuthSession(
      userId: 'dev-user-001',
      displayName: provider == AuthProvider.google
          ? 'Movaro Google User'
          : 'Movaro Apple User',
      provider: provider,
      isAuthenticated: true,
    );

    return _session;
  }

  @override
  Future<AuthSession> completeOnboarding({
    required String originCountry,
    required String destinationCountry,
  }) async {
    _session = _session.copyWith(
      originCountry: originCountry,
      destinationCountry: destinationCountry,
    );

    return _session;
  }

  @override
  Future<void> signOut() async {
    _session = const AuthSession.guest();
  }
}
