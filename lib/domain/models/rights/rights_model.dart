import 'package:json_annotation/json_annotation.dart';

part 'rights_model.g.dart';

@JsonSerializable()
class RightsModel {
  final int locationId;
  final String email;

  RightsModel({
    required this.locationId,
    required this.email
  });

  static RightsModel fromJson(Map<String, dynamic> json) => _$RightsModelFromJson(json);
  Map<String, dynamic> toJson() => _$RightsModelToJson(this);
}