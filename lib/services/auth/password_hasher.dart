import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

/// Salted SHA-256 password hashing. Not bcrypt/argon2, but real hashing
/// with per-user random salt — no plaintext passwords are ever stored.
/// A production backend should upgrade this to bcrypt/argon2 server-side;
/// this client-side implementation is intentionally swappable behind
/// [AuthRepository] once a real API exists.
class PasswordHasher {
  PasswordHasher._();

  static String generateSalt([int length = 16]) {
    final rand = Random.secure();
    final bytes = List<int>.generate(length, (_) => rand.nextInt(256));
    return base64UrlEncode(bytes);
  }

  static String hash(String password, String salt) {
    final bytes = utf8.encode('$salt::$password');
    return sha256.convert(bytes).toString();
  }

  static bool verify(String password, String salt, String expectedHash) {
    return hash(password, salt) == expectedHash;
  }
}
