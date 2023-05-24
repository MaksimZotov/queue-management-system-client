import 'package:json_annotation/json_annotation.dart';

import '../../enums/rights_status.dart';

part 'rights_model.g.dart';

@JsonSerializable()
class RightsModel {
  @JsonKey(name: 'location_id')
  final int locationId;
  final String email;
  final RightsStatus status;

  RightsModel({
    required this.locationId,
    required this.email,
    required this.status
  });

  static RightsModel fromJson(Map<String, dynamic> json) => _$RightsModelFromJson(json);
  Map<String, dynamic> toJson() => _$RightsModelToJson(this);
}