import 'package:json_annotation/json_annotation.dart';

part 'service.g.dart';

@JsonSerializable()
class Service {
  final int id;
  final String name;
  @JsonKey(name: 'order_number')
  final int orderNumber;

  Service(
    this.id,
    this.name,
    this.orderNumber
  );

  static Service fromJson(Map<String, dynamic> json) => _$ServiceFromJson(json);
  Map<String, dynamic> toJson() => _$ServiceToJson(this);
}