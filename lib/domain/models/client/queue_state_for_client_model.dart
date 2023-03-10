import '../../enums/client_in_queue_status.dart';
import 'package:json_annotation/json_annotation.dart';

part 'queue_state_for_client_model.g.dart';

@JsonSerializable()
class QueueStateForClientModel {
  @JsonKey(name: 'in_queue')
  final bool inQueue;

  @JsonKey(name: 'queue_name')
  final String queueName;

  final String? email;
  final int code;
  final ClientInQueueStatus? status;

  QueueStateForClientModel({
    required this.inQueue,
    required this.queueName,
    this.email,
    required this.code,
    this.status
  });

  static QueueStateForClientModel fromJson(Map<String, dynamic> json) => _$QueueStateForClientModelFromJson(json);
  Map<String, dynamic> toJson() => _$QueueStateForClientModelToJson(this);
}