import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@lazySingleton
class SharedPreferencesStorage {
  static const _clientId = 'CLIENT_ID';
  static const _clientAccessKey = 'CLIENT_ACCESS_KEY';

  Future<void> setClientId({required int? clientId}) async {
    final prefs = await SharedPreferences.getInstance();
    if (clientId == null) {
      await prefs.remove(_clientId);
    } else {
      await prefs.setInt(_clientId, clientId);
    }
  }

  Future<int?> getClientId() async {
    final prefs = await SharedPreferences.getInstance();
    int? clientId = prefs.getInt(_clientId);
    return clientId;
  }

  Future<void> setClientAccessKey({required String? accessKey}) async {
    final prefs = await SharedPreferences.getInstance();
    if (accessKey == null) {
      await prefs.remove(_clientAccessKey);
    } else {
      await prefs.setString(_clientAccessKey, accessKey);
    }
  }

  Future<String?> getClientAccessKey() async {
    final prefs = await SharedPreferences.getInstance();
    String? accessKey = prefs.getString(_clientAccessKey);
    return accessKey;
  }

}