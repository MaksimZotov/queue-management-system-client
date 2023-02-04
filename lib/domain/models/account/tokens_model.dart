import 'package:json_annotation/json_annotation.dart';

part 'tokens_model.g.dart';

@JsonSerializable()
class TokensModel {
  final String access;
  final String refresh;
  final String email;

  TokensModel({
    required this.access,
    required this.refresh,
    required this.email
  });

  static TokensModel fromJson(Map<String, dynamic> json) => _$TokensModelFromJson(json);
  Map<String, dynamic> toJson() => _$TokensModelToJson(this);
}