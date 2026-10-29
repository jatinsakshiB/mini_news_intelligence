import 'package:shared_preferences/shared_preferences.dart';

abstract class AuthLocalDataSource {
  Future<bool> isLoggedIn();
  Future<String?> getUserEmail();
  Future<String?> getSavedPasswordHash();
  Future<void> saveUserSession({
    required String email,
    required String passwordHash,
  });
  Future<void> clearUserSession();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyUserEmail = 'user_email';
  static const String _keyPasswordHash = 'password_hash';

  final SharedPreferences sharedPreferences;

  AuthLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<bool> isLoggedIn() async {
    return sharedPreferences.getBool(_keyIsLoggedIn) ?? false;
  }

  @override
  Future<String?> getUserEmail() async {
    return sharedPreferences.getString(_keyUserEmail);
  }

  @override
  Future<String?> getSavedPasswordHash() async {
    return sharedPreferences.getString(_keyPasswordHash);
  }

  @override
  Future<void> saveUserSession({
    required String email,
    required String passwordHash,
  }) async {
    await sharedPreferences.setBool(_keyIsLoggedIn, true);
    await sharedPreferences.setString(_keyUserEmail, email);
    await sharedPreferences.setString(_keyPasswordHash, passwordHash);
  }

  @override
  Future<void> clearUserSession() async {
    await sharedPreferences.setBool(_keyIsLoggedIn, false);
    // Keep email for convenient next login, or clear if needed
  }
}
