import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class AndroidNativeInteractor {
  static const _lockTaskChannel = 'lockTaskChannel';
  static const _enableLockTask = 'enableLockTask';

  final MethodChannel _methodChannel = const MethodChannel(_lockTaskChannel);

  Future<bool> enableLockTask() async {
    return await _methodChannel.invokeMethod(_enableLockTask);
  }
}