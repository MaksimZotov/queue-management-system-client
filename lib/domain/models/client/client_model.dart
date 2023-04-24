import '../../enums/client_in_queue_status.dart';
import 'package:json_annotation/json_annotation.dart';

part 'client_model.g.dart';

@JsonSerializable()
class ClientModel {
  final int id;
  final String? phone;
  final int? code;
  final ClientInQueueStatus status;

  ClientModel({
    required this.id,
    required this.phone,
    required this.code,
    required this.status
  });

  static ClientModel fromJson(Map<String, dynamic> json) => _$ClientModelFromJson(json);
  Map<String, dynamic> toJson() => _$ClientModelToJson(this);
}