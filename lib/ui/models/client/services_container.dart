import 'package:queue_management_system_client/domain/models/location/state/service.dart';

class ServicesContainer {
  final int priorityNumber;
  final List<Service> services;

  ServicesContainer({
    required this.priorityNumber,
    required this.services
  });
}