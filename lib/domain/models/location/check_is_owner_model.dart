import 'package:json_annotation/json_annotation.dart';

part 'check_is_owner_model.g.dart';

@JsonSerializable()
class CheckIsOwnerModel {
  @JsonKey(name: 'is_owner')
  final bool isOwner;

  CheckIsOwnerModel({
    required this.isOwner
  });

  static CheckIsOwnerModel fromJson(Map<String, dynamic> json) => _$CheckIsOwnerModelFromJson(json);
  Map<String, dynamic> toJson() => _$CheckIsOwnerModelToJson(this);
}