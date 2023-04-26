import 'package:json_annotation/json_annotation.dart';

import 'client.dart';

part 'location_state.g.dart';

@JsonSerializable()
class LocationState {
  final int? id;
  final List<Client> clients;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  LocationState(
    this.id,
    this.clients,
    this.createdAt
  );

  static LocationState fromJson(Map<String, dynamic> json) => _$LocationStateFromJson(json);
  Map<String, dynamic> toJson() => _$LocationStateToJson(this);
}