import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/data/converters/json_converter.dart';
import 'package:queue_management_system_client/domain/models/verification/login_model.dart';

@singleton
class LoginFields {
  final String username = 'username';
  final String password = 'password';
}

@singleton
class LoginConverter extends JsonConverter<LoginModel> {
  final LoginFields _loginFields;
  LoginConverter(this._loginFields);

  @override
  LoginModel fromJson(Map<String, dynamic> json) => LoginModel(
    username: json[_loginFields.username] as String,
    password: json[_loginFields.password] as String
  );

  @override
  Map<String, dynamic> toJson(LoginModel data) => {
    _loginFields.username: data.username,
    _loginFields.password: data.password,
  };
}