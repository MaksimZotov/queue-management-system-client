import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/data/converters/json_converter.dart';
import 'package:queue_management_system_client/domain/models/location/location_model.dart';

import '../../../domain/models/client/client_model.dart';
import '../../../domain/models/queue/add_client_info.dart';

@singleton
class AddClientInfoFields {
  final String firstName = 'first_name';
  final String lastName = 'last_name';
}

@singleton
class AddClientInfoConverter extends JsonConverter<AddClientInfo> {
  final AddClientInfoFields _clientFields;
  AddClientInfoConverter(this._clientFields);

  @override
  AddClientInfo fromJson(Map<String, dynamic> json) => AddClientInfo(
      firstName: json[_clientFields.firstName] as String,
      lastName: json[_clientFields.lastName] as String
  );

  @override
  Map<String, dynamic> toJson(AddClientInfo data) => {
    _clientFields.firstName: data.firstName,
    _clientFields.lastName: data.lastName
  };
}