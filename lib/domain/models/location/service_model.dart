import 'package:json_annotation/json_annotation.dart';

part 'service_model.g.dart';

@JsonSerializable()
class ServiceModel {
  final int id;
  final String name;
  final String? description;
  @JsonKey(name: 'supposed_duration')
  final int supposedDuration;
  @JsonKey(name: 'max_duration')
  final int maxDuration;

  ServiceModel(
      this.id,
      this.name,
      this.description,
      this.supposedDuration,
      this.maxDuration
  );

  static ServiceModel fromJson(Map<String, dynamic> json) => _$ServiceModelFromJson(json);
  Map<String, dynamic> toJson() => _$ServiceModelToJson(this);
}