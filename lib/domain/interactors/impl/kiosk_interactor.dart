import 'package:injectable/injectable.dart';

import '../../../data/repositories/repository.dart';
import '../../models/kiosk/kiosk_state.dart';
import '../kiosk_interactor.dart';

@Singleton(as: KioskInteractor)
class KioskInteractorImpl extends KioskInteractor {
  final Repository _repository;

  KioskInteractorImpl(this._repository);

  @override
  Future<void> setKioskState(KioskState kioskState) {
    return _repository.setKioskState(kioskState);
  }

  @override
  Future<KioskState?> getKioskState() {
    return _repository.getKioskState();
  }

  @override
  Future<void> clearKioskState() {
    return _repository.clearKioskState();
  }
}