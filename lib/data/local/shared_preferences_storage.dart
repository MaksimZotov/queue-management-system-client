import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@lazySingleton
class SharedPreferencesStorage {
  static const _clientInQueueEmail = 'CLIENT_IN_QUEUE_EMAIL';
  static const _clientInQueueAccessKey = 'CLIENT_IN_QUEUE_ACCESS_KEY';

  Future<void> setClientInQueueEmail({required String? email}) async {
    final prefs = await SharedPreferences.getInstance();
    if (email == null) {
      await prefs.remove(_clientInQueueEmail);
    } else {
      await prefs.setString(_clientInQueueEmail, email);
    }
  }

  Future<String?> getClientInQueueEmail() async {
    final prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString(_clientInQueueEmail);
    return email;
  }

  Future<void> setClientInQueueAccessKey({required String? accessKey}) async {
    final prefs = await SharedPreferences.getInstance();
    if (accessKey == null) {
      await prefs.remove(_clientInQueueAccessKey);
    } else {
      await prefs.setString(_clientInQueueAccessKey, accessKey);
    }
  }

  Future<String?> getClientInQueueAccessKey() async {
    final prefs = await SharedPreferences.getInstance();
    String? accessKey = prefs.getString(_clientInQueueAccessKey);
    return accessKey;
  }

}