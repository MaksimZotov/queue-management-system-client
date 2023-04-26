import 'package:json_annotation/json_annotation.dart';

import 'queue.dart';
import 'service.dart';

part 'client.g.dart';

@JsonSerializable()
class Client {
  final int id;
  final int code;
  final String? phone;
  @JsonKey(name: 'wait_timestamp')
  final DateTime waitTimestamp;
  final List<Service> services;
  final Queue? queue;

  int get waitTimeInMinutes {
    int start = waitTimestamp.millisecondsSinceEpoch;
    int end = DateTime.now().millisecondsSinceEpoch;
    return ((end - start) / 60000).round();
  }

  Client({
    required this.id,
    required this.code,
    required this.phone,
    required this.waitTimestamp,
    required this.services,
    required this.queue
  });

  static Client fromJson(Map<String, dynamic> json) => _$ClientFromJson(json);
  Map<String, dynamic> toJson() => _$ClientToJson(this);
}