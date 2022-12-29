class SignupModel {
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String password;
  final String repeatPassword;

  SignupModel({
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.password,
    required this.repeatPassword
  });

  SignupModel copyWith({
    String? username,
    String? email,
    String? firstName,
    String? lastName,
    String? password,
    String? repeatPassword
  }) => SignupModel(
      username: username ?? this.username,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      password: password ?? this.password,
      repeatPassword: repeatPassword ?? this.repeatPassword
  );
}