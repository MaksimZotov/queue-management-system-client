import 'package:json_annotation/json_annotation.dart';

enum RightsStatus {
  @JsonValue('EMPLOYEE')
  employee,
  @JsonValue('ADMINISTRATOR')
  administrator;
}