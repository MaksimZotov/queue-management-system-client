import 'package:json_annotation/json_annotation.dart';

part 'client_join_info.g.dart';

@JsonSerializable()
class ClientJoinInfo {
  final String email;
  @JsonKey(name: 'first_name')
  final String firstName;
  @JsonKey(name: 'last_name')
  final String lastName;

  ClientJoinInfo({
    required this.email,
    required this.firstName,
    required this.lastName,
  });

  static ClientJoinInfo fromJson(Map<String, dynamic> json) => _$ClientJoinInfoFromJson(json);
  Map<String, dynamic> toJson() => _$ClientJoinInfoToJson(this);
}