import 'package:json_annotation/json_annotation.dart';

part 'check_is_owner_model.g.dart';

@JsonSerializable()
class CheckIsOwnerModel {
  @JsonKey(name: 'has_rights')
  final bool hasRights;

  CheckIsOwnerModel({
    required this.hasRights
  });

  static CheckIsOwnerModel fromJson(Map<String, dynamic> json) => _$CheckIsOwnerModelFromJson(json);
  Map<String, dynamic> toJson() => _$CheckIsOwnerModelToJson(this);
}