import 'package:flutter/foundation.dart';
import 'package:movaro_app/app/router/app_routes.dart';
import 'package:movaro_app/features/auth/domain/entities/auth_provider.dart';
import 'package:movaro_app/features/auth/domain/entities/auth_session.dart';
import 'package:movaro_app/features/auth/domain/repositories/auth_repository.dart';

class AuthController extends ChangeNotifier {
  AuthController({required AuthRepository repository})
    : _repository = repository,
      _session = const AuthSession.guest();

  final AuthRepository _repository;

  AuthSession _session;
  String? _pendingRoute;
  bool _isInitialized = false;
  bool _isBusy = false;

  AuthSession get session => _session;
  bool get isAuthenticated => _session.isAuthenticated;
  bool get needsOnboarding => _session.needsOnboarding;
  bool get isInitialized => _isInitialized;
  bool get isBusy => _isBusy;
  String? get pendingRoute => _pendingRoute;

  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    _session = await _repository.restoreSession();
    _isInitialized = true;
    notifyListeners();
  }

  void rememberPendingRoute(String route) {
    _pendingRoute = route;
  }

  Future<void> signIn(AuthProvider provider) async {
    _setBusy(true);
    try {
      _session = await _repository.signIn(provider);
      notifyListeners();
    } finally {
      _setBusy(false);
    }
  }

  Future<void> completeOnboarding({
    required String originCountry,
    required String destinationCountry,
  }) async {
    _setBusy(true);
    try {
      _session = await _repository.completeOnboarding(
        originCountry: originCountry,
        destinationCountry: destinationCountry,
      );
      notifyListeners();
    } finally {
      _setBusy(false);
    }
  }

  Future<void> signOut() async {
    _setBusy(true);
    try {
      await _repository.signOut();
      _session = const AuthSession.guest();
      _pendingRoute = null;
      notifyListeners();
    } finally {
      _setBusy(false);
    }
  }

  String resolveRouteAfterLogin() {
    if (needsOnboarding) {
      return AppRoutes.onboarding;
    }

    final nextRoute = _pendingRoute;
    _pendingRoute = null;
    return nextRoute ?? AppRoutes.authenticatedHome;
  }

  String resolveRouteAfterOnboarding() {
    final nextRoute = _pendingRoute;
    _pendingRoute = null;
    return nextRoute ?? AppRoutes.authenticatedHome;
  }

  void _setBusy(bool value) {
    _isBusy = value;
    notifyListeners();
  }
}
