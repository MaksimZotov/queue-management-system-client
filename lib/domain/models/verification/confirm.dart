class ConfirmModel {
  final String username;
  final String code;

  ConfirmModel({
    required this.username,
    required this.code
  });

  ConfirmModel copyWith({
    String? username,
    String? code
  }) => ConfirmModel(
      username: username ?? this.username,
      code: code ?? this.code
  );
}