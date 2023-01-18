import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/data/converters/json_converter.dart';
import 'package:queue_management_system_client/domain/models/location/has_rights_model.dart';

@singleton
class HasRightsFields {
  final String hasRights = 'has_rights';
}

@singleton
class HasRightsConverter extends JsonConverter<HasRightsModel> {
  final HasRightsFields _hasRightsFields;
  HasRightsConverter(this._hasRightsFields);

  @override
  HasRightsModel fromJson(Map<String, dynamic> json) => HasRightsModel(
      hasRights: json[_hasRightsFields.hasRights] as bool
  );

  @override
  Map<String, dynamic> toJson(HasRightsModel data) => {
    _hasRightsFields.hasRights: data.hasRights
  };
}