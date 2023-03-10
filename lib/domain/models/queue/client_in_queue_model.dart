import '../../enums/client_in_queue_status.dart';
import 'package:json_annotation/json_annotation.dart';

part 'client_in_queue_model.g.dart';

@JsonSerializable()
class ClientInQueueModel {
  final int id;
  final String? email;
  final int code;
  final ClientInQueueStatus status;
  final List<String> services;

  ClientInQueueModel({
    required this.id,
    required this.email,
    required this.code,
    required this.status,
    required this.services
  });

  static ClientInQueueModel fromJson(Map<String, dynamic> json) => _$ClientInQueueModelFromJson(json);
  Map<String, dynamic> toJson() => _$ClientInQueueModelToJson(this);
}