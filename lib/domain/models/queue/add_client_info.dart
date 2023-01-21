import 'package:json_annotation/json_annotation.dart';

part 'add_client_info.g.dart';

@JsonSerializable()
class AddClientInfo {
  @JsonKey(name: 'first_name')
  final String firstName;
  @JsonKey(name: 'last_name')
  final String lastName;

  AddClientInfo({
    required this.firstName,
    required this.lastName,
  });

  static AddClientInfo fromJson(Map<String, dynamic> json) => _$AddClientInfoFromJson(json);
  Map<String, dynamic> toJson() => _$AddClientInfoToJson(this);
}