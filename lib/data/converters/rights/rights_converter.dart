import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/data/converters/json_converter.dart';
import 'package:queue_management_system_client/domain/models/queue/client_in_queue_model.dart';
import 'package:queue_management_system_client/domain/models/rights/rights_model.dart';

import '../../../domain/enums/client_in_queue_status.dart';

@singleton
class RightsFields {
  final String locationId = 'location_id';
  final String email = 'email';
}

@singleton
class RightsConverter extends JsonConverter<RightsModel> {
  final RightsFields _rightsField;
  RightsConverter(this._rightsField);

  @override
  RightsModel fromJson(Map<String, dynamic> json) => RightsModel(
    locationId: json[_rightsField.locationId] as int,
    email: json[_rightsField.email] as String,
  );

  @override
  Map<String, dynamic> toJson(RightsModel data) => {
    _rightsField.locationId: data.locationId,
    _rightsField.email: data.email
  };
}