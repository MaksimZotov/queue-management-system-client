import 'package:json_annotation/json_annotation.dart';

part 'create_service_request.g.dart';

@JsonSerializable()
class CreateServiceRequest {
  final String name;
  final String? description;

  CreateServiceRequest({
      required this.name,
      this.description
  });

  static CreateServiceRequest fromJson(Map<String, dynamic> json) => _$CreateServiceRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateServiceRequestToJson(this);
}