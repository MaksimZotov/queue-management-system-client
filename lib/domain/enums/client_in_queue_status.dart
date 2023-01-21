import 'package:json_annotation/json_annotation.dart';

enum ClientInQueueStatus {
  @JsonValue('CONFIRMED')
  confirmed,
  @JsonValue('RESERVED')
  reserved;
}