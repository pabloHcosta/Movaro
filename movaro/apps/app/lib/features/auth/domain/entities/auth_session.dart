import 'package:movaro_app/features/auth/domain/entities/auth_provider.dart';

class AuthSession {
  const AuthSession({
    required this.userId,
    required this.displayName,
    required this.provider,
    required this.isAuthenticated,
    this.originCountry,
    this.destinationCountry,
  });

  const AuthSession.guest()
    : userId = '',
      displayName = 'Guest',
      provider = null,
      isAuthenticated = false,
      originCountry = null,
      destinationCountry = null;

  final String userId;
  final String displayName;
  final AuthProvider? provider;
  final bool isAuthenticated;
  final String? originCountry;
  final String? destinationCountry;

  bool get needsOnboarding =>
      isAuthenticated &&
      (originCountry == null ||
          originCountry!.isEmpty ||
          destinationCountry == null ||
          destinationCountry!.isEmpty);

  AuthSession copyWith({
    String? userId,
    String? displayName,
    AuthProvider? provider,
    bool? isAuthenticated,
    String? originCountry,
    String? destinationCountry,
    bool clearOriginCountry = false,
    bool clearDestinationCountry = false,
  }) {
    return AuthSession(
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      provider: provider ?? this.provider,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      originCountry: clearOriginCountry
          ? null
          : originCountry ?? this.originCountry,
      destinationCountry: clearDestinationCountry
          ? null
          : destinationCountry ?? this.destinationCountry,
    );
  }
}
