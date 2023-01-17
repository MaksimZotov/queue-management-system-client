import '../../enums/client_in_queue_status.dart';

class ClientModel {
  final bool inQueue;

  final String queueName;
  final int queueLength;

  final String? email;
  final String? firstName;
  final String? lastName;
  final int? beforeMe;
  final String? accessKey;
  final ClientInQueueStatus? status;

  ClientModel({
    required this.inQueue,
    required this.queueName,
    required this.queueLength,
    this.email,
    this.firstName,
    this.lastName,
    this.beforeMe,
    this.accessKey,
    this.status
  });

}