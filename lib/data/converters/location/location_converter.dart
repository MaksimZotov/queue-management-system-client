import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/data/converters/json_converter.dart';
import 'package:queue_management_system_client/domain/models/location/location_model.dart';

@singleton
class LocationFields {
  final String id = 'id';
  final String name = 'name';
  final String description = 'description';
  final String hasRules = 'has_rules';
}

@singleton
class LocationConverter extends JsonConverter<LocationModel> {
  final LocationFields _locationFields;
  LocationConverter(this._locationFields);

  @override
  LocationModel fromJson(Map<String, dynamic> json) => LocationModel(
    id: json[_locationFields.id] as int?,
    name: json[_locationFields.name] as String,
    description: json[_locationFields.description] as String,
      hasRules: json[_locationFields.hasRules] as bool?
  );

  @override
  Map<String, dynamic> toJson(LocationModel data) => {
    _locationFields.id: data.id,
    _locationFields.name: data.name,
    _locationFields.description: data.description,
    _locationFields.hasRules: data.hasRules
  };
}