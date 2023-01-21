import '../../enums/client_in_queue_status.dart';
import 'package:json_annotation/json_annotation.dart';

part 'client_model.g.dart';

@JsonSerializable()
class ClientModel {
  @JsonKey(name: 'in_queue')
  final bool inQueue;

  @JsonKey(name: 'queue_name')
  final String queueName;
  @JsonKey(name: 'queue_length')
  final int queueLength;

  final String? email;
  @JsonKey(name: 'first_name')
  final String? firstName;
  @JsonKey(name: 'last_name')
  final String? lastName;
  @JsonKey(name: 'before_me')
  final int? beforeMe;
  @JsonKey(name: 'access_key')
  final String? accessKey;
  final ClientInQueueStatus? status;

  ClientModel({
    required this.inQueue,
    required this.queueName,
    required this.queueLength,
    this.email,
    this.firstName,
    this.lastName,
    this.beforeMe,
    this.accessKey,
    this.status
  });

  static ClientModel fromJson(Map<String, dynamic> json) => _$ClientModelFromJson(json);
  Map<String, dynamic> toJson() => _$ClientModelToJson(this);
}