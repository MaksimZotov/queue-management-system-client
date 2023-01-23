import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:injectable/injectable.dart';

import '../../../data/repositories/repository.dart';
import '../queue_interactor.dart';
import '../socket_interactor.dart';

@Singleton(as: SocketInteractor)
class SocketInteractorImpl extends SocketInteractor {
  final Repository _repository;

  SocketInteractorImpl(this._repository);

  @override
  void connectToSocket<T>(String destination, VoidCallback onConnected, ValueChanged<T> onQueueChanged, ValueChanged onError) {
    _repository.connectToSocket(destination, onConnected, onQueueChanged, onError);
  }

  @override
  void disconnectFromSocket(String destination) {
    _repository.disconnectFromSocket(destination);
  }
}