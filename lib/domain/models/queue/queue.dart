import 'client_in_queue.dart';

class QueueModel {
  final int? id;
  final String name;
  final String description;
  final List<ClientInQueueModel>? clients;
  final bool? hasRules;

  QueueModel({
    this.id,
    required this.name,
    required this.description,
    this.clients,
    this.hasRules
  });
}