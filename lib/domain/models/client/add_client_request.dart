import 'package:json_annotation/json_annotation.dart';

part 'add_client_request.g.dart';

@JsonSerializable()
class AddClientRequest {
  final String email;
  @JsonKey(name: 'first_name')
  final String firstName;
  @JsonKey(name: 'last_name')
  final String lastName;
  @JsonKey(name: 'service_ids')
  final List<int>? serviceIds;
  @JsonKey(name: 'services_sequence_id')
  final int? servicesSequenceId;

  AddClientRequest({
    required this.email,
    required this.firstName,
    required this.lastName,
    this.serviceIds,
    this.servicesSequenceId
  });

  static AddClientRequest fromJson(Map<String, dynamic> json) => _$AddClientRequestFromJson(json);
  Map<String, dynamic> toJson() => _$AddClientRequestToJson(this);
}