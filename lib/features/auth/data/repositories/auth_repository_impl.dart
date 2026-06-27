import 'package:nahriva/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:nahriva/features/auth/domain/entities/user.dart';
import 'package:nahriva/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl(this._remoteDataSource);

  @override
  Stream<User?> get authStateChanges => _remoteDataSource.authStateChanges;

  @override
  User? get currentUser => _remoteDataSource.currentUser;

  @override
  Future<void> login(String email, String password) {
    return _remoteDataSource.login(email, password);
  }

  @override
  Future<void> register(String email, String password, String displayName) {
    return _remoteDataSource.register(email, password, displayName);
  }

  @override
  Future<void> logout() {
    return _remoteDataSource.logout();
  }

  @override
  Future<void> forgotPassword(String email) {
    return _remoteDataSource.forgotPassword(email);
  }
}
