import 'package:movaro_app/features/auth/data/datasources/auth_data_source.dart';
import 'package:movaro_app/features/auth/domain/entities/auth_provider.dart';
import 'package:movaro_app/features/auth/domain/entities/auth_session.dart';
import 'package:movaro_app/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({required AuthDataSource dataSource})
    : _dataSource = dataSource;

  final AuthDataSource _dataSource;

  @override
  Future<AuthSession> restoreSession() => _dataSource.restoreSession();

  @override
  Future<AuthSession> signIn(AuthProvider provider) =>
      _dataSource.signIn(provider);

  @override
  Future<AuthSession> completeOnboarding({
    required String originCountry,
    required String destinationCountry,
  }) {
    return _dataSource.completeOnboarding(
      originCountry: originCountry,
      destinationCountry: destinationCountry,
    );
  }

  @override
  Future<void> signOut() => _dataSource.signOut();
}
