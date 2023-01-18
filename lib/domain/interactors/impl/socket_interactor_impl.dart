

import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/domain/models/client/client_join_info_model.dart';
import 'package:queue_management_system_client/domain/models/queue/client_in_queue_model.dart';

import '../../../data/repositories/repository.dart';
import '../../models/base/container_for_list.dart';
import '../../models/base/result.dart';
import '../../models/queue/add_client_info.dart';
import '../../models/queue/queue_model.dart';
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