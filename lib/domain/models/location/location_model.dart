import 'package:json_annotation/json_annotation.dart';

part 'location_model.g.dart';

@JsonSerializable()
class LocationModel {
  final int? id;
  @JsonKey(name: 'owner_username')
  final String? ownerUsername;
  final String name;
  final String description;
  @JsonKey(name: 'has_rights')
  final bool? hasRights;

  LocationModel({
    required this.id,
    this.ownerUsername,
    required this.name,
    required this.description,
    this.hasRights
  });

  static LocationModel fromJson(Map<String, dynamic> json) => _$LocationModelFromJson(json);
  Map<String, dynamic> toJson() => _$LocationModelToJson(this);
}