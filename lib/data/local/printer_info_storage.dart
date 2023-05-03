import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';


@lazySingleton
class PrinterInfoStorage {
  static const _printerEnabled = 'PRINTER_ENABLED';

  Future<void> setPrinterEnabled(bool printerEnabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_printerEnabled, printerEnabled);
  }

  Future<bool> getPrinterEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_printerEnabled) ?? false;
  }
}