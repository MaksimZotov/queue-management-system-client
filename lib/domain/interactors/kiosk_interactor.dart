import '../models/kiosk/printer_data.dart';

abstract class KioskInteractor {
  Future<PrinterData> getPrinterData();
  Future<void> enableKioskMode(PrinterData printerDate);
}