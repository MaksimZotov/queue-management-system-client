import 'package:queue_management_system_client/domain/models/location/service_model.dart';

class ServiceWrapper {
  final bool selected;
  final int orderNumber;
  final ServiceModel service;

  ServiceWrapper({
    this.selected = false,
    this.orderNumber = 0,
    required this.service
  });

  ServiceWrapper copy({
    bool? selected,
    int? orderNumber
  }) => ServiceWrapper(
    selected: selected ?? this.selected,
    orderNumber: orderNumber ?? this.orderNumber,
    service: service
  );
}