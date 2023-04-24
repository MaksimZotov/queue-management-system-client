import 'package:json_annotation/json_annotation.dart';

part 'add_client_request.g.dart';

@JsonSerializable()
class AddClientRequest {
  final String? phone;
  @JsonKey(name: 'service_ids')
  final List<int>? serviceIds;
  @JsonKey(name: 'services_sequence_id')
  final int? servicesSequenceId;
  @JsonKey(name: 'confirmation_required')
  final bool confirmationRequired;

  AddClientRequest({
    required this.phone,
    required this.serviceIds,
    required this.servicesSequenceId,
    required this.confirmationRequired
  });

  static AddClientRequest fromJson(Map<String, dynamic> json) => _$AddClientRequestFromJson(json);
  Map<String, dynamic> toJson() => _$AddClientRequestToJson(this);
}