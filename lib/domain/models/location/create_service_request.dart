import 'package:json_annotation/json_annotation.dart';

part 'create_service_request.g.dart';

@JsonSerializable()
class CreateServiceRequest {
  final String name;
  final String? description;
  @JsonKey(name: 'supposed_duration')
  final int supposedDuration;
  @JsonKey(name: 'max_duration')
  final int maxDuration;

  CreateServiceRequest({
      required this.name,
      this.description,
      required this.supposedDuration,
      required this.maxDuration
  });

  static CreateServiceRequest fromJson(Map<String, dynamic> json) => _$CreateServiceRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateServiceRequestToJson(this);
}