import 'package:flutter/cupertino.dart';
import 'package:json_annotation/json_annotation.dart';

part 'result.g.dart';

class Result<T> {
  Result<T> onSuccess(ValueChanged<SuccessResult<T>> action) {
    if (this is SuccessResult<T>) {
      action.call(this as SuccessResult<T>);
    }
    return this;
  }
  Result<T> onError(ValueChanged<ErrorResult<T>> action) {
    if (this is ErrorResult<T>) {
      action.call(this as ErrorResult<T>);
    }
    return this;
  }
}


class SuccessResult<T> extends Result<T> {
  final T data;

  SuccessResult({required this.data});
}


enum ErrorType {
  standard,
  unknown,
  server,
  timeout,
  connection
}

@JsonSerializable()
class ErrorResult<T> extends Result<T> {
  @JsonKey(defaultValue: ErrorType.standard)
  final ErrorType type;
  final String? description;
  final Map<String, String>? errors;

  ErrorResult({required this.type, this.description, this.errors});

  static ErrorResult fromJson(Map<String, dynamic> json) => _$ErrorResultFromJson(json);
  Map<String, dynamic> toJson() => _$ErrorResultToJson(this);
}