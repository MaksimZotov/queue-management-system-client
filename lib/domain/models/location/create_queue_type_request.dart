import 'package:json_annotation/json_annotation.dart';

part 'create_queue_type_request.g.dart';

@JsonSerializable()
class CreateQueueTypeRequest {
  final String name;
  final String? description;

  CreateQueueTypeRequest({
    required this.name,
    required this.description
  });

  static CreateQueueTypeRequest fromJson(Map<String, dynamic> json) => _$CreateQueueTypeRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateQueueTypeRequestToJson(this);
}