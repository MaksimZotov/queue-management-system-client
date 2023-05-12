import 'package:json_annotation/json_annotation.dart';

import '../../enums/rights_status.dart';

part 'location_model.g.dart';

@JsonSerializable()
class LocationModel {
  final int? id;
  @JsonKey(name: 'owner_email')
  final String? ownerEmail;
  final String name;
  final String? description;

  LocationModel({
    required this.id,
    this.ownerEmail,
    required this.name,
    this.description
  });

  static LocationModel fromJson(Map<String, dynamic> json) => _$LocationModelFromJson(json);
  Map<String, dynamic> toJson() => _$LocationModelToJson(this);
}