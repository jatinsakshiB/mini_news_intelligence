import '../../../../core/errors/failures.dart';
import '../../../../core/utils/password_hasher.dart';
import '../datasources/auth_local_datasource.dart';

abstract class AuthRepository {
  Future<bool> isLoggedIn();
  Future<String?> getCurrentUserEmail();
  Future<void> login({required String email, required String password});
  Future<void> logout();
}

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({required this.localDataSource});

  @override
  Future<bool> isLoggedIn() async {
    return localDataSource.isLoggedIn();
  }

  @override
  Future<String?> getCurrentUserEmail() async {
    return localDataSource.getUserEmail();
  }

  @override
  Future<void> login({required String email, required String password}) async {
    final cleanEmail = email.trim().toLowerCase();
    final cleanPassword = password.trim();

    if (cleanEmail.isEmpty || !cleanEmail.contains('@')) {
      throw const AuthFailure(message: 'Please enter a valid email address.');
    }

    if (cleanPassword.length < 6) {
      throw const AuthFailure(
        message: 'Password must be at least 6 characters.',
      );
    }

    final savedEmail = await localDataSource.getUserEmail();
    final savedHash = await localDataSource.getSavedPasswordHash();

    // If an existing user is registered with this email, verify password hash
    if (savedEmail != null &&
        savedEmail.toLowerCase() == cleanEmail &&
        savedHash != null) {
      final isValid = PasswordHasher.verify(cleanPassword, savedHash);
      if (!isValid) {
        throw const AuthFailure(
          message: 'Incorrect password for this account.',
        );
      }
    }

    // Save session with hashed password
    final passwordHash = PasswordHasher.hashPassword(cleanPassword);
    await localDataSource.saveUserSession(
      email: cleanEmail,
      passwordHash: passwordHash,
    );
  }

  @override
  Future<void> logout() async {
    await localDataSource.clearUserSession();
  }
}
