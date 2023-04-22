import 'package:injectable/injectable.dart';

import '../../../data/repositories/repository.dart';
import '../kiosk_interactor.dart';

@Singleton(as: KioskInteractor)
class KioskInteractorImpl extends KioskInteractor {
  final Repository _repository;

  KioskInteractorImpl(this._repository);

  @override
  Future<bool> getPrinterEnabled() {
    return _repository.getPrinterEnabled();
  }

  @override
  Future<bool> enableKioskMode(bool printerEnabled) {
    return _repository.enableKioskMode(printerEnabled);
  }
}