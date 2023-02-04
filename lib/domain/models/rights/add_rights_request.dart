import 'package:json_annotation/json_annotation.dart';
import 'package:queue_management_system_client/domain/enums/rights_status.dart';

part 'add_rights_request.g.dart';

@JsonSerializable()
class AddRightsRequest {
  final String email;
  final RightsStatus status;

  AddRightsRequest({
    required this.email,
    required this.status
  });

  static AddRightsRequest fromJson(Map<String, dynamic> json) => _$AddRightsRequestFromJson(json);
  Map<String, dynamic> toJson() => _$AddRightsRequestToJson(this);
}