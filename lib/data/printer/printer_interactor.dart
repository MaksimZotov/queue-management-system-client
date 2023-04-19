import 'package:injectable/injectable.dart';
import 'package:esc_pos_printer/esc_pos_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';

@lazySingleton
class PrinterInteractor {

  Future<bool> print(String ipAddress, String port) async {
    const PaperSize paper = PaperSize.mm80;
    final CapabilityProfile profile = await CapabilityProfile.load();
    final NetworkPrinter printer = NetworkPrinter(paper, profile);

    int? portInt = int.tryParse(port);
    if (portInt == null) {
      return false;
    }

    final PosPrintResult res = await printer.connect(
        ipAddress,
        port: portInt
    );

    if (res == PosPrintResult.success) {
      test(printer);
      printer.disconnect();
      return true;
    }
    return false;
  }

  void test(NetworkPrinter printer) {
    printer.text('Regular: aA bB cC dD eE fF gG hH iI jJ kK lL mM nN oO pP qQ rR sS tT uU vV wW xX yY zZ');
    printer.cut();
  }
}