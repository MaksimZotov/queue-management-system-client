import 'package:json_annotation/json_annotation.dart';
import 'package:queue_management_system_client/domain/enums/location_change_event.dart';
import 'package:queue_management_system_client/domain/models/location/change/base/location_change_model.dart';

import '../client.dart';

part 'location_add_client.g.dart';

@JsonSerializable()
class LocationAddClient extends LocationChange {
  final LocationChangeEvent event;
  final Client client;

  LocationAddClient(
      this.event,
      this.client
  );

  static LocationAddClient fromJson(Map<String, dynamic> json) => _$LocationAddClientFromJson(json);
  Map<String, dynamic> toJson() => _$LocationAddClientToJson(this);
}