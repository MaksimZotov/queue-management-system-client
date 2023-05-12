import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class AccountInfoStorage {
  final _storage = const FlutterSecureStorage();

  static const _accessToken = 'ACCESS_TOKEN';
  static const _refreshToken = 'REFRESH_TOKEN';
  static const _accountId = 'ACCOUNT_ID';

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

  Future<void> setAccountId({required int accountId}) async {
    return await _storage.write(key: _accountId, value: accountId.toString());
  }

  Future<int?> getAccountId() async {
    return int.tryParse(await _storage.read(key: _accountId) ?? '');
  }

  Future<bool> containsAccountId() async {
    return await _storage.containsKey(key: _accountId);
  }

  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }

}