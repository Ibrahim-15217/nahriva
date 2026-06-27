import 'package:nahriva/features/auth/domain/entities/user.dart';

abstract class AuthRepository {
  Stream<User?> get authStateChanges;
  User? get currentUser;
  Future<void> login(String email, String password);
  Future<void> register(String email, String password, String displayName);
  Future<void> logout();
  Future<void> forgotPassword(String email);
}
