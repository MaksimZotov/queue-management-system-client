import 'package:json_annotation/json_annotation.dart';

part 'create_services_sequence_request.g.dart';

@JsonSerializable()
class CreateServicesSequenceRequest {
  final String name;
  final String? description;
  @JsonKey(name: 'service_ids_to_order_numbers')
  Map<int, int> serviceIdsToOrderNumbers;

  CreateServicesSequenceRequest({
      required this.name,
      this.description,
      required this.serviceIdsToOrderNumbers
  });

  static CreateServicesSequenceRequest fromJson(Map<String, dynamic> json) => _$CreateServicesSequenceRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateServicesSequenceRequestToJson(this);
}