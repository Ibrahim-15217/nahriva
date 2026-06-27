import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahriva/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:nahriva/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:nahriva/features/auth/domain/entities/user.dart';
import 'package:nahriva/features/auth/domain/repositories/auth_repository.dart';
import 'package:nahriva/features/auth/domain/usecases/forgot_password.dart';
import 'package:nahriva/features/auth/domain/usecases/login.dart';
import 'package:nahriva/features/auth/domain/usecases/logout.dart';
import 'package:nahriva/features/auth/domain/usecases/register.dart';

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dataSource = ref.watch(authRemoteDataSourceProvider);
  return AuthRepositoryImpl(dataSource);
});

final loginProvider = Provider<Login>((ref) {
  return Login(ref.watch(authRepositoryProvider));
});

final registerProvider = Provider<Register>((ref) {
  return Register(ref.watch(authRepositoryProvider));
});

final logoutProvider = Provider<Logout>((ref) {
  return Logout(ref.watch(authRepositoryProvider));
});

final forgotPasswordProvider = Provider<ForgotPassword>((ref) {
  return ForgotPassword(ref.watch(authRepositoryProvider));
});

final authStateProvider = StreamProvider<User?>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return repository.authStateChanges;
});

final currentUserProvider = Provider<User?>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return repository.currentUser;
});
