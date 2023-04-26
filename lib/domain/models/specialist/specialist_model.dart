import 'package:json_annotation/json_annotation.dart';

part 'specialist_model.g.dart';

@JsonSerializable()
class SpecialistModel {
  final int id;
  final String name;
  final String? description;

  SpecialistModel(
      this.id,
      this.name,
      this.description
  );

  static SpecialistModel fromJson(Map<String, dynamic> json) => _$SpecialistModelFromJson(json);
  Map<String, dynamic> toJson() => _$SpecialistModelToJson(this);
}