import 'package:json_annotation/json_annotation.dart';

part 'service.g.dart';

@JsonSerializable()
class Service {
  final int id;
  final String name;

  Service(
    this.id,
    this.name
  );

  static Service fromJson(Map<String, dynamic> json) => _$ServiceFromJson(json);
  Map<String, dynamic> toJson() => _$ServiceToJson(this);
}