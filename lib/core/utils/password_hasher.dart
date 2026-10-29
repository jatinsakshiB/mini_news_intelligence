import 'dart:convert';
import 'package:crypto/crypto.dart';

class PasswordHasher {
  PasswordHasher._();

  static const String _salt = 'balaji_news_secure_salt_2026';

  /// Hashes a plain password with SHA-256 and salt.
  static String hashPassword(String password) {
    final bytes = utf8.encode('$_salt:$password');
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Verifies if a given plain password matches a hashed password.
  static bool verify(String plainPassword, String hashedPassword) {
    return hashPassword(plainPassword) == hashedPassword;
  }
}
