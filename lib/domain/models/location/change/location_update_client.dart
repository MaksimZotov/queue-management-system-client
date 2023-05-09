import 'package:json_annotation/json_annotation.dart';
import 'package:queue_management_system_client/domain/enums/location_change_event.dart';

import '../client.dart';
import 'base/location_change_model.dart';

part 'location_update_client.g.dart';

@JsonSerializable()
class LocationUpdateClient extends LocationChange {
  final LocationChangeEvent event;
  final Client client;

  LocationUpdateClient(
      this.event,
      this.client
  );

  static LocationUpdateClient fromJson(Map<String, dynamic> json) => _$LocationUpdateClientFromJson(json);
  Map<String, dynamic> toJson() => _$LocationUpdateClientToJson(this);
}