import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/data/converters/json_converter.dart';
import 'package:queue_management_system_client/domain/models/location/location.dart';

@singleton
class LocationFields {
  final String id = 'id';
  final String name = 'name';
  final String description = 'description';
}

@singleton
class LocationConverter extends JsonConverter<LocationModel> {
  final LocationFields _clientInRoomFields;
  LocationConverter(this._clientInRoomFields);

  @override
  LocationModel fromJson(Map<String, dynamic> json) => LocationModel(
    id: json[_clientInRoomFields.id] as int?,
    name: json[_clientInRoomFields.name] as String,
    description: json[_clientInRoomFields.description] as String
  );

  @override
  Map<String, dynamic> toJson(LocationModel data) => {
    _clientInRoomFields.id: data.id,
    _clientInRoomFields.name: data.name,
    _clientInRoomFields.description: data.description
  };
}