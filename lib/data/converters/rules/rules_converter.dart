import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/data/converters/json_converter.dart';
import 'package:queue_management_system_client/domain/models/queue/client_in_queue_model.dart';
import 'package:queue_management_system_client/domain/models/rules/rules_model.dart';

import '../../../domain/enums/client_in_queue_status.dart';

@singleton
class RulesFields {
  final String locationId = 'location_id';
  final String email = 'email';
}

@singleton
class RulesConverter extends JsonConverter<RulesModel> {
  final RulesFields _rulesField;
  RulesConverter(this._rulesField);

  @override
  RulesModel fromJson(Map<String, dynamic> json) => RulesModel(
    locationId: json[_rulesField.locationId] as int,
    email: json[_rulesField.email] as String,
  );

  @override
  Map<String, dynamic> toJson(RulesModel data) => {
    _rulesField.locationId: data.locationId,
    _rulesField.email: data.email
  };
}