import 'package:nahriva/features/auth/domain/repositories/auth_repository.dart';

class Register {
  final AuthRepository _repository;

  Register(this._repository);

  Future<void> call(String email, String password, String displayName) {
    return _repository.register(email, password, displayName);
  }
}
