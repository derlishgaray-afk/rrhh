import 'dart:convert';

import 'package:crypto/crypto.dart';

class PasswordHasher {
  PasswordHasher._();

  static String hash({required String username, required String password}) {
    final normalizedUser = username.trim().toLowerCase();
    final normalizedPassword = password;
    final payload = '$normalizedUser::$normalizedPassword';
    return sha256.convert(utf8.encode(payload)).toString();
  }

  static bool verify({
    required String username,
    required String password,
    required String expectedHash,
  }) {
    final hashValue = hash(username: username, password: password);
    return hashValue == expectedHash;
  }
}
