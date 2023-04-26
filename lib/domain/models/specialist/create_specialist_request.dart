import 'package:json_annotation/json_annotation.dart';

part 'create_specialist_request.g.dart';

@JsonSerializable()
class CreateSpecialistRequest {
  final String name;
  final String? description;
  final List<int> serviceIds;

  CreateSpecialistRequest({
    required this.name,
    this.description,
    required this.serviceIds
  });

  static CreateSpecialistRequest fromJson(Map<String, dynamic> json) => _$CreateSpecialistRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateSpecialistRequestToJson(this);
}