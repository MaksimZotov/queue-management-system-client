import 'package:queue_management_system_client/domain/enums/terminal_mode.dart';

class TerminalState {
  final TerminalMode terminalMode;
  final bool multipleSelect;

  TerminalState({
    required this.terminalMode,
    required this.multipleSelect
  });
}