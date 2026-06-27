import 'package:nahriva/features/auth/domain/repositories/auth_repository.dart';

class ForgotPassword {
  final AuthRepository _repository;

  ForgotPassword(this._repository);

  Future<void> call(String email) {
    return _repository.forgotPassword(email);
  }
}
