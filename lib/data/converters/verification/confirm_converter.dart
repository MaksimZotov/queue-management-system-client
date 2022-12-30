import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/data/converters/json_converter.dart';
import 'package:queue_management_system_client/domain/models/verification/Confirm.dart';

@singleton
class ConfirmFields {
  final String username = 'username';
  final String code = 'code';
}

@singleton
class ConfirmConverter extends JsonConverter<ConfirmModel> {
  final ConfirmFields _confirmFields;
  ConfirmConverter(this._confirmFields);

  @override
  ConfirmModel fromJson(Map<String, dynamic> json) => ConfirmModel(
      username: json[_confirmFields.username] as String,
      code: json[_confirmFields.code] as String
  );

  @override
  Map<String, dynamic> toJson(ConfirmModel data) => {
    _confirmFields.username: data.username,
    _confirmFields.code: data.code,
  };
}