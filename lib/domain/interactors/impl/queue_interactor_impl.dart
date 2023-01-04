

import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:injectable/injectable.dart';

import '../../../data/repositories/repository.dart';
import '../../models/base/container_for_list.dart';
import '../../models/base/result.dart';
import '../../models/queue/queue_model.dart';
import '../queue_interactor.dart';

@Singleton(as: QueueInteractor)
class QueueInteractorImpl extends QueueInteractor {
  final Repository _repository;

  QueueInteractorImpl(this._repository);

  @override
  Future<Result<ContainerForList<QueueModel>>> getQueues(int locationId, int page, int pageSize, String? username) async {
    return await _repository.getQueues(locationId, page, pageSize, username);
  }

  @override
  Future<Result<QueueModel>> createQueue(int locationId, QueueModel queue) async {
    return await _repository.createQueue(locationId, queue);
  }

  @override
  Future<Result> deleteQueue(int id) async {
    return await _repository.deleteQueue(id);
  }

  @override
  Future<Result<QueueModel>> getQueueState(int id) async {
    return await _repository.getQueueState(id);
  }

  @override
  Future<Result> notifyClientInQueue(int queueId, String email) async {
    return await _repository.notifyClientInQueue(queueId, email);
  }

  @override
  Future<Result> serveClientInQueue(int queueId, String email) async {
    return await _repository.serveClientInQueue(queueId, email);
  }

  @override
  void connectToQueueSocket(int queueId, VoidCallback onConnected, ValueChanged<QueueModel> onQueueChanged, ValueChanged onError) {
    _repository.connectToQueueSocket(queueId, onConnected, onQueueChanged, onError);
  }

  @override
  void disconnectFromQueueSocket(int queueId) {
    _repository.disconnectFromQueueSocket(queueId);
  }
}