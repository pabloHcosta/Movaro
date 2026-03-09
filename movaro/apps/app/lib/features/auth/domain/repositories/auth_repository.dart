import 'package:movaro_app/features/auth/domain/entities/auth_provider.dart';
import 'package:movaro_app/features/auth/domain/entities/auth_session.dart';

abstract class AuthRepository {
  Future<AuthSession> restoreSession();

  Future<AuthSession> signIn(AuthProvider provider);

  Future<AuthSession> completeOnboarding({
    required String originCountry,
    required String destinationCountry,
  });

  Future<void> signOut();
}
