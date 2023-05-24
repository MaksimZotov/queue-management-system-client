import 'package:json_annotation/json_annotation.dart';

part 'create_client_request.g.dart';

@JsonSerializable()
class CreateClientRequest {
  final String? phone;
  @JsonKey(name: 'service_ids')
  final List<int>? serviceIds;
  @JsonKey(name: 'services_sequence_id')
  final int? servicesSequenceId;
  @JsonKey(name: 'confirmation_required')
  final bool confirmationRequired;

  CreateClientRequest({
    required this.phone,
    required this.serviceIds,
    required this.servicesSequenceId,
    required this.confirmationRequired
  });

  static CreateClientRequest fromJson(Map<String, dynamic> json) => _$CreateClientRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateClientRequestToJson(this);
}