import 'client_in_queue_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'create_queue_request.g.dart';

@JsonSerializable()
class CreateQueueRequest {
  @JsonKey(name: 'queue_type_id')
  final int specialistId;
  final String name;
  final String? description;

  CreateQueueRequest({
    required this.specialistId,
    required this.name,
    this.description
  });

  static CreateQueueRequest fromJson(Map<String, dynamic> json) => _$CreateQueueRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateQueueRequestToJson(this);
}