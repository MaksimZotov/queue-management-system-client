import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/data/converters/json_converter.dart';
import 'package:queue_management_system_client/domain/models/verification/signup.dart';

@singleton
class SignupFields {
  final String username = 'username';
  final String email = 'email';
  final String firstName = 'first_name';
  final String lastName = 'last_name';
  final String password = 'password';
  final String repeatPassword = 'repeat_password';
}

@singleton
class SignupConverter extends JsonConverter<SignupModel> {
  final SignupFields _signupFields;
  SignupConverter(this._signupFields);

  @override
  SignupModel fromJson(Map<String, dynamic> json) => SignupModel(
    username: json[_signupFields.username] as String,
    email: json[_signupFields.email] as String,
    firstName: json[_signupFields.firstName] as String,
    lastName: json[_signupFields.lastName] as String,
    password: json[_signupFields.password] as String,
    repeatPassword: json[_signupFields.repeatPassword] as String
  );

  @override
  Map<String, dynamic> toJson(SignupModel data) => {
    _signupFields.username: data.username,
    _signupFields.email: data.email,
    _signupFields.firstName: data.firstName,
    _signupFields.lastName: data.lastName,
    _signupFields.password: data.password,
    _signupFields.repeatPassword: data.repeatPassword
  };
}