import 'package:json_annotation/json_annotation.dart';
import 'package:queue_management_system_client/domain/models/location/queue.dart';
import 'package:queue_management_system_client/domain/models/location/service.dart';

import 'client.dart';

part 'location_state.g.dart';

@JsonSerializable()
class LocationState {
  final int? id;
  final List<Client> clients;

  LocationState({
    required this.id,
    required this.clients,
  });

  LocationState copy({
    List<Client>? clients,
    List<Queue>? queues,
    List<Service>? services
  }) => LocationState(
    id: id,
    clients: clients ?? this.clients
  );

  static LocationState fromJson(Map<String, dynamic> json) => _$LocationStateFromJson(json);
  Map<String, dynamic> toJson() => _$LocationStateToJson(this);
}