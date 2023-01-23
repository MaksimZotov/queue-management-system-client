import '../../enums/client_in_queue_status.dart';
import 'package:json_annotation/json_annotation.dart';

part 'client_in_queue_model.g.dart';

@JsonSerializable()
class ClientInQueueModel {
  final int id;
  final String? email;
  @JsonKey(name: 'first_name')
  final String firstName;
  @JsonKey(name: 'last_name')
  final String lastName;
  @JsonKey(name: 'order_number')
  final int orderNumber;
  @JsonKey(name: 'public_code')
  final int publicCode;
  @JsonKey(name: 'access_key')
  final String accessKey;
  final ClientInQueueStatus status;

  ClientInQueueModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.orderNumber,
    required this.publicCode,
    required this.accessKey,
    required this.status
  });

  static ClientInQueueModel fromJson(Map<String, dynamic> json) => _$ClientInQueueModelFromJson(json);
  Map<String, dynamic> toJson() => _$ClientInQueueModelToJson(this);
}