import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/data/converters/json_converter.dart';
import 'package:queue_management_system_client/domain/models/account/tokens_model.dart';

@singleton
class TokensFields {
  final String access = 'access';
  final String refresh = 'refresh';
  final String username = 'username';
}

@singleton
class TokensConverter extends JsonConverter<TokensModel> {
  final TokensFields _tokensFields;
  TokensConverter(this._tokensFields);

  @override
  TokensModel fromJson(Map<String, dynamic> json) => TokensModel(
    access: json[_tokensFields.access] as String,
    refresh: json[_tokensFields.refresh] as String,
    username: json[_tokensFields.username] as String,
  );

  @override
  Map<String, dynamic> toJson(TokensModel data) => {
    _tokensFields.access: data.access,
    _tokensFields.refresh: data.refresh,
    _tokensFields.username: data.username
  };
}