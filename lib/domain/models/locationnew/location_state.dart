import 'package:json_annotation/json_annotation.dart';

import 'client.dart';

part 'location_state.g.dart';

@JsonSerializable()
class LocationState {
  @JsonKey(name: 'location_id')
  final int locationId;
  List<Client> clients;

  LocationState(
    this.locationId,
    this.clients
  );

  static LocationState fromJson(Map<String, dynamic> json) => _$LocationStateFromJson(json);
  Map<String, dynamic> toJson() => _$LocationStateToJson(this);
}