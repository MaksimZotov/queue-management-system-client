import 'package:json_annotation/json_annotation.dart';

part 'create_location_request.g.dart';

@JsonSerializable()
class CreateLocationRequest {
  final String name;
  final String? description;

  CreateLocationRequest({
    required this.name,
    this.description,
  });

  static CreateLocationRequest fromJson(Map<String, dynamic> json) => _$CreateLocationRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateLocationRequestToJson(this);
}