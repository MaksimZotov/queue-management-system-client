import 'package:json_annotation/json_annotation.dart';

part 'change_client_request.g.dart';

@JsonSerializable()
class ChangeClientRequest {
  @JsonKey(name: 'client_id')
  final int clientId;
  @JsonKey(name: 'service_ids_to_order_numbers')
  Map<int, int> serviceIdsToOrderNumbers;

  ChangeClientRequest({
    required this.clientId,
    required this.serviceIdsToOrderNumbers,
  });

  static ChangeClientRequest fromJson(Map<String, dynamic> json) => _$ChangeClientRequestFromJson(json);
  Map<String, dynamic> toJson() => _$ChangeClientRequestToJson(this);
}