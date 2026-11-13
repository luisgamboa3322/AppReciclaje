import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class TokenStorage {
  Future<String?> readAccessToken();
  Future<String?> readRefreshToken();
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  });
  Future<void> clear();
}

class MemoryTokenStorage implements TokenStorage {
  String? _accessToken;
  String? _refreshToken;

  @override
  Future<String?> readAccessToken() async => _accessToken;

  @override
  Future<String?> readRefreshToken() async => _refreshToken;

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
  }

  @override
  Future<void> clear() async {
    _accessToken = null;
    _refreshToken = null;
  }
}

class SecureTokenStorage implements TokenStorage {
  SecureTokenStorage([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  static const _accessKey = 'pecox_access_token';
  static const _refreshKey = 'pecox_refresh_token';

  final FlutterSecureStorage _storage;
  final MemoryTokenStorage _fallback = MemoryTokenStorage();

  @override
  Future<String?> readAccessToken() async {
    try {
      return await _storage.read(key: _accessKey);
    } on MissingPluginException {
      return _fallback.readAccessToken();
    } on PlatformException {
      return _fallback.readAccessToken();
    }
  }

  @override
  Future<String?> readRefreshToken() async {
    try {
      return await _storage.read(key: _refreshKey);
    } on MissingPluginException {
      return _fallback.readRefreshToken();
    } on PlatformException {
      return _fallback.readRefreshToken();
    }
  }

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _fallback.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
    try {
      await _storage.write(key: _accessKey, value: accessToken);
      await _storage.write(key: _refreshKey, value: refreshToken);
    } on MissingPluginException {
      // Fallback already persisted in memory for headless/test runs.
    } on PlatformException {
      // Fallback already persisted in memory when keystore is unavailable.
    }
  }

  @override
  Future<void> clear() async {
    await _fallback.clear();
    try {
      await _storage.delete(key: _accessKey);
      await _storage.delete(key: _refreshKey);
    } on MissingPluginException {
      // Ignore missing platform channel in unit tests.
    } on PlatformException {
      // Ignore platform keystore errors cleanly on sign-out.
    }
  }
}
