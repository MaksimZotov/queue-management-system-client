import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/data/converters/json_converter.dart';
import 'package:queue_management_system_client/domain/models/location/has_rules_model.dart';

@singleton
class HasRulesFields {
  final String hasRules = 'has_rules';
}

@singleton
class HasRulesConverter extends JsonConverter<HasRulesModel> {
  final HasRulesFields _hasRulesFields;
  HasRulesConverter(this._hasRulesFields);

  @override
  HasRulesModel fromJson(Map<String, dynamic> json) => HasRulesModel(
      hasRules: json[_hasRulesFields.hasRules] as bool
  );

  @override
  Map<String, dynamic> toJson(HasRulesModel data) => {
    _hasRulesFields.hasRules: data.hasRules
  };
}