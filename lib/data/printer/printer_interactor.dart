import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_usb_printer/flutter_usb_printer.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class PrinterInteractor {

  final FlutterUsbPrinter flutterUsbPrinter = FlutterUsbPrinter();

  Future<void> print(String text, int code) async {
    try {
      await flutterUsbPrinter.write(
          Uint8List.fromList(utf8.encode("$text\n$code"))
      );
    } on PlatformException { /* Do nothing */ }
  }

  Future<bool> connectToPrinter() async {
    try {
      List<Map<String, dynamic>> results = await FlutterUsbPrinter.getUSBDeviceList();
      if (results.length != 1) {
        return false;
      }
      Map<String, dynamic> device = results[0];
      int? vendorId = int.tryParse(device['vendorId']);
      int? productId = int.tryParse(device['productId']);
      if (vendorId == null || productId == null) {
        return false;
      }
      return await flutterUsbPrinter.connect(vendorId, productId) ?? false;
    } on PlatformException {
      return false;
    }
  }
}