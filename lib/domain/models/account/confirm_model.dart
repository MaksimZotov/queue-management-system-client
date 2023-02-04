import 'package:json_annotation/json_annotation.dart';

part 'confirm_model.g.dart';

@JsonSerializable()
class ConfirmModel {
  final String email;
  final String code;

  ConfirmModel({
    required this.email,
    required this.code
  });

  static ConfirmModel fromJson(Map<String, dynamic> json) => _$ConfirmModelFromJson(json);
  Map<String, dynamic> toJson() => _$ConfirmModelToJson(this);
}