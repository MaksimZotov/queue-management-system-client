import 'package:json_annotation/json_annotation.dart';

part 'signup_model.g.dart';

@JsonSerializable()
class SignupModel {
  final String email;
  @JsonKey(name: 'first_name')
  final String firstName;
  @JsonKey(name: 'last_name')
  final String lastName;
  final String password;
  @JsonKey(name: 'repeat_password')
  final String repeatPassword;

  SignupModel({
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.password,
    required this.repeatPassword
  });

  static SignupModel fromJson(Map<String, dynamic> json) => _$SignupModelFromJson(json);
  Map<String, dynamic> toJson() => _$SignupModelToJson(this);
}