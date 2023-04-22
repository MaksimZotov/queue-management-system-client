abstract class KioskInteractor {
  Future<bool> getPrinterEnabled();
  Future<bool> enableKioskMode(bool printerEnabled);
}