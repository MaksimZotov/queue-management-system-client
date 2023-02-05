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
  @JsonKey(name: 'is_owner')
  final bool isOwner;
  @JsonKey(name: 'rights_status')
  final RightsStatus? rightsStatus;

  LocationModel({
    required this.id,
    this.ownerEmail,
    required this.name,
    this.description,
    required this.isOwner,
    this.rightsStatus
  });

  static LocationModel fromJson(Map<String, dynamic> json) => _$LocationModelFromJson(json);
  Map<String, dynamic> toJson() => _$LocationModelToJson(this);
}