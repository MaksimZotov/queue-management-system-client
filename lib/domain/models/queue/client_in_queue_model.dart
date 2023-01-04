import '../../enums/client_in_queue_status.dart';

class ClientInQueueModel {
  final String email;
  final String firstName;
  final String lastName;
  final int orderNumber;
  final ClientInQueueStatus status;

  ClientInQueueModel({
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.orderNumber,
    required this.status
  });
}