import 'package:json_annotation/json_annotation.dart';
import 'package:queue_management_system_client/domain/enums/location_change_event.dart';

import 'base/location_change_model.dart';

part 'location_delete_client.g.dart';

@JsonSerializable()
class LocationDeleteClient extends LocationChange {
  final LocationChangeEvent event;
  @JsonKey(name: 'client_id')
  int clientId;

  LocationDeleteClient(
      this.event,
      this.clientId
  );

  static LocationDeleteClient fromJson(Map<String, dynamic> json) => _$LocationDeleteClientFromJson(json);
  Map<String, dynamic> toJson() => _$LocationDeleteClientToJson(this);
}