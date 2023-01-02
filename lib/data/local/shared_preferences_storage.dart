import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@lazySingleton
class SharedPreferencesStorage {
  static const _clientInQueueEmail = 'CLIENT_IN_QUEUE_EMAIL';

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

}