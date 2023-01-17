import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class SecureStorage {
  final _storage = const FlutterSecureStorage();

  static const _accessToken = 'ACCESS_TOKEN';
  static const _refreshToken = 'REFRESH_TOKEN';
  static const _username = 'USERNAME';

  Future<void> setAccessToken({required String accessToken}) async {
    return await _storage.write(key: _accessToken, value: accessToken);
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessToken);
  }

  Future<bool> containsAccessToken() async {
    return await _storage.containsKey(key: _accessToken);
  }

  Future<void> setRefreshToken({required String refreshToken}) async {
    return await _storage.write(key: _refreshToken, value: refreshToken);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshToken);
  }

  Future<bool> containsRefreshToken() async {
    return await _storage.containsKey(key: _refreshToken);
  }

  Future<void> setUsername({required String username}) async {
    return await _storage.write(key: _username, value: username);
  }

  Future<String?> getUsername() async {
    return await _storage.read(key: _username);
  }

  Future<bool> containsUsername() async {
    return await _storage.containsKey(key: _username);
  }

  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }

}