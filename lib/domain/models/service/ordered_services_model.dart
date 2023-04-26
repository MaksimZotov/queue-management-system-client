import 'package:json_annotation/json_annotation.dart';

part 'ordered_services_model.g.dart';

@JsonSerializable()
class OrderedServicesModel {
  @JsonKey(name: 'service_ids_to_order_numbers')
  Map<int, int> serviceIdsToOrderNumbers;

  OrderedServicesModel(
      this.serviceIdsToOrderNumbers
  );

  static OrderedServicesModel fromJson(Map<String, dynamic> json) => _$OrderedServicesModelFromJson(json);
  Map<String, dynamic> toJson() => _$OrderedServicesModelToJson(this);
}