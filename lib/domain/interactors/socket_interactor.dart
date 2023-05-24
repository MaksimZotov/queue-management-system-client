import 'package:flutter/cupertino.dart';

abstract class SocketInteractor {
  void connectToSocket<T>(String destination, VoidCallback onConnected, ValueChanged<T> onQueueChanged, ValueChanged onError);
  void disconnectFromSocket(String destination);
}