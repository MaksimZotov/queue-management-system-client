import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@lazySingleton
class AccountInfoStorage {
  static const _accessToken = 'ACCESS_TOKEN';
  static const _refreshToken = 'REFRESH_TOKEN';
  static const _accountId = 'ACCOUNT_ID';

  Future<void> setAccessToken({required String accessToken}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessToken, accessToken);
  }

  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessToken);
  }

  Future<bool> containsAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_accessToken);
  }

  Future<void> setRefreshToken({required String refreshToken}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_refreshToken, refreshToken);
  }

  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshToken);
  }

  Future<bool> containsRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_refreshToken);
  }

  Future<void> setAccountId({required int accountId}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_accountId, accountId);
  }

  Future<int?> getAccountId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_accountId);
  }

  Future<bool> containsAccountId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_accountId);
  }

  Future<void> deleteAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessToken);
    await prefs.remove(_refreshToken);
    await prefs.remove(_accountId);
  }

}