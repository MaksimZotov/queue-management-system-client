class LoginModel {
  final String username;
  final String password;

  LoginModel({
    required this.username,
    required this.password
  });

  LoginModel copyWith({
    String? username,
    String? password
  }) => LoginModel(
      username: username ?? this.username,
      password: password ?? this.password
  );
}