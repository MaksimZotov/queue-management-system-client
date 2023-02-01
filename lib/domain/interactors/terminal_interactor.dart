import '../models/terminal/terminal_state.dart';

abstract class TerminalInteractor {
  Future<void> setTerminalState(TerminalState terminalState);
  Future<TerminalState?> getTerminalState();
  Future<void> clearTerminalState();
}