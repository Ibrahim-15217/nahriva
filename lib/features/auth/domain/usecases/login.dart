import 'package:nahriva/features/auth/domain/repositories/auth_repository.dart';

class Login {
  final AuthRepository _repository;

  Login(this._repository);

  Future<void> call(String email, String password) {
    return _repository.login(email, password);
  }
}
