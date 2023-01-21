import 'package:json_annotation/json_annotation.dart';

part 'confirm_model.g.dart';

@JsonSerializable()
class ConfirmModel {
  final String username;
  final String code;

  ConfirmModel({
    required this.username,
    required this.code
  });

  static ConfirmModel fromJson(Map<String, dynamic> json) => _$ConfirmModelFromJson(json);
  Map<String, dynamic> toJson() => _$ConfirmModelToJson(this);
}