import '../../enums/client_in_queue_status.dart';

class ClientInQueueModel {
  final int id;
  final String? email;
  final String firstName;
  final String lastName;
  final int orderNumber;
  final String accessKey;
  final ClientInQueueStatus status;

  ClientInQueueModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.orderNumber,
    required this.accessKey,
    required this.status
  });
}