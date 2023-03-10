import 'package:json_annotation/json_annotation.dart';

import 'queue.dart';
import 'service.dart';

part 'client.g.dart';

@JsonSerializable()
class Client {
  final int id;
  final int code;
  @JsonKey(name: 'wait_timestamp')
  final DateTime waitTimestamp;
  final List<Service> services;
  final Queue? queue;
  @JsonKey(name: 'services_in_queue')
  final List<Service> servicesInQueue;

  Client(
    this.id,
    this.code,
    this.waitTimestamp,
    this.services,
    this.queue,
    this.servicesInQueue
  );

  static Client fromJson(Map<String, dynamic> json) => _$ClientFromJson(json);
  Map<String, dynamic> toJson() => _$ClientToJson(this);
}