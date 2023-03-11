import 'package:json_annotation/json_annotation.dart';

part 'serve_client_request.g.dart';

@JsonSerializable()
class ServeClientRequest {
  @JsonKey(name: 'client_id')
  final int clientId;
  @JsonKey(name: 'queue_id')
  final int queueId;
  final List<int> services;

  ServeClientRequest({
    required this.clientId,
    required this.queueId,
    required this.services
  });

  static ServeClientRequest fromJson(Map<String, dynamic> json) => _$ServeClientRequestFromJson(json);
  Map<String, dynamic> toJson() => _$ServeClientRequestToJson(this);
}