import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class AndroidNativeInteractor {
  final MethodChannel _lockTaskChannel = const MethodChannel('lockTaskChannel');

  Future<void> enableLockTask() async {
    await _lockTaskChannel.invokeMethod('enableLockTask');
  }

  Future<void> disableLockTask() async {
    await _lockTaskChannel.invokeMethod('disableLockTask');
  }
}