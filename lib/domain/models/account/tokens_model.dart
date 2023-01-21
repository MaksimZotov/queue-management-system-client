import 'package:json_annotation/json_annotation.dart';

part 'tokens_model.g.dart';

@JsonSerializable()
class TokensModel {
  final String access;
  final String refresh;
  final String username;

  TokensModel({
    required this.access,
    required this.refresh,
    required this.username
  });

  static TokensModel fromJson(Map<String, dynamic> json) => _$TokensModelFromJson(json);
  Map<String, dynamic> toJson() => _$TokensModelToJson(this);
}