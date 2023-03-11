import '../../enums/client_in_queue_status.dart';
import 'package:json_annotation/json_annotation.dart';

part 'queue_state_for_client_model.g.dart';

@JsonSerializable()
class QueueStateForClientModel {
  @JsonKey(name: 'client_id')
  final int clientId;
  @JsonKey(name: 'location_id')
  final int locationId;
  final String? email;
  final int code;

  QueueStateForClientModel({
    required this.clientId,
    required this.locationId,
    this.email,
    required this.code
  });

  static QueueStateForClientModel fromJson(Map<String, dynamic> json) => _$QueueStateForClientModelFromJson(json);
  Map<String, dynamic> toJson() => _$QueueStateForClientModelToJson(this);
}