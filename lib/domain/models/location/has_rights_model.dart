import 'package:json_annotation/json_annotation.dart';

part 'has_rights_model.g.dart';

@JsonSerializable()
class HasRightsModel {
  @JsonKey(name: 'has_rights')
  final bool hasRights;

  HasRightsModel({
    required this.hasRights
  });

  static HasRightsModel fromJson(Map<String, dynamic> json) => _$HasRightsModelFromJson(json);
  Map<String, dynamic> toJson() => _$HasRightsModelToJson(this);
}