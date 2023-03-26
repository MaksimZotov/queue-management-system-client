import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/domain/models/kiosk/printer_data.dart';

import '../../../data/repositories/repository.dart';
import '../kiosk_interactor.dart';

@Singleton(as: KioskInteractor)
class KioskInteractorImpl extends KioskInteractor {
  final Repository _repository;

  KioskInteractorImpl(this._repository);

  @override
  Future<PrinterData> getPrinterData() {
    return _repository.getPrinterData();
  }

  @override
  Future<void> enableKioskMode(PrinterData printerDate) {
    return _repository.enableKioskMode(printerDate);
  }
}