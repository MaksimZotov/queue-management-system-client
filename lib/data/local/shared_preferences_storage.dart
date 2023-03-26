import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/domain/models/kiosk/printer_data.dart';
import 'package:shared_preferences/shared_preferences.dart';


@lazySingleton
class SharedPreferencesStorage {
  static const _printerDataIp = 'PRINTER_DATA_IP';
  static const _printerDataPort = 'PRINTER_DATA_PORT';

  Future<void> setPrinterData(PrinterData printerData) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_printerDataIp, printerData.ip);
    prefs.setString(_printerDataPort, printerData.port);
  }

  Future<PrinterData> getPrinterData() async {
    final prefs = await SharedPreferences.getInstance();
    String? ip = prefs.getString(_printerDataIp);
    if (ip == null) {
      return PrinterData(ip: "", port: "");
    }
    String? port = prefs.getString(_printerDataPort);
    if (port == null) {
      return PrinterData(ip: ip, port: "");
    }
    return PrinterData(ip: ip, port: port);
  }
}