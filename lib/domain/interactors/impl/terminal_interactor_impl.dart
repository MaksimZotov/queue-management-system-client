import 'package:injectable/injectable.dart';

import '../../../data/repositories/repository.dart';
import '../../models/terminal/terminal_state.dart';
import '../terminal_interactor.dart';

@Singleton(as: TerminalInteractor)
class TerminalInteractorImpl extends TerminalInteractor {
  final Repository _repository;

  TerminalInteractorImpl(this._repository);

  @override
  Future<void> setTerminalState(TerminalState terminalState) {
    return _repository.setTerminalState(terminalState);
  }

  @override
  Future<TerminalState?> getTerminalState() {
    return _repository.getTerminalState();
  }

  @override
  Future<void> clearTerminalState() {
    return _repository.clearTerminalState();
  }
}