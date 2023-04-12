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
    printer.text(
        'Regular: aA bB cC dD eE fF gG hH iI jJ kK lL mM nN oO pP qQ rR sS tT uU vV wW xX yY zZ');
    printer.text('Special 1: àÀ èÈ éÉ ûÛ üÜ çÇ ôÔ',
        styles: PosStyles(codeTable: 'CP1252'));
    printer.text('Special 2: blåbærgrød',
        styles: PosStyles(codeTable: 'CP1252'));

    printer.text('Bold text', styles: PosStyles(bold: true));
    printer.text('Reverse text', styles: PosStyles(reverse: true));
    printer.text('Underlined text',
        styles: PosStyles(underline: true), linesAfter: 1);
    printer.text('Align left', styles: PosStyles(align: PosAlign.left));
    printer.text('Align center', styles: PosStyles(align: PosAlign.center));
    printer.text('Align right',
        styles: PosStyles(align: PosAlign.right), linesAfter: 1);

    printer.text('Text size 200%',
        styles: PosStyles(
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ));

    printer.feed(2);
    printer.cut();
  }
}