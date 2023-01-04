import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/data/converters/json_converter.dart';
import 'package:queue_management_system_client/domain/models/base/result.dart';

@singleton
class ErrorResultFields {
  final String description = 'description';
  final String errors = 'errors';
}

@singleton
class ErrorResultConverter extends JsonConverter<ErrorResult> {
  final ErrorResultFields _errorResultFields;
  ErrorResultConverter(this._errorResultFields);

  @override
  ErrorResult fromJson(Map<String, dynamic> json) => ErrorResult(
      description: json[_errorResultFields.description] as String?,
      errors: Map.from(json[_errorResultFields.errors]).map((key, value) =>
        MapEntry(
          key as String,
          value as String
        )
      )
  );

  @override
  Map<String, dynamic> toJson(ErrorResult data) => {
    _errorResultFields.description: data.description,
    _errorResultFields.errors: data.errors
  };
}