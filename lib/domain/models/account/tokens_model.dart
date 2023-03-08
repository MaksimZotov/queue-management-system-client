import 'package:json_annotation/json_annotation.dart';

part 'tokens_model.g.dart';

@JsonSerializable()
class TokensModel {
  final String access;
  final String refresh;
  @JsonKey(name: 'account_id')
  final int accountId;

  TokensModel({
    required this.access,
    required this.refresh,
    required this.accountId
  });

  static TokensModel fromJson(Map<String, dynamic> json) => _$TokensModelFromJson(json);
  Map<String, dynamic> toJson() => _$TokensModelToJson(this);
}