import 'package:flutter/cupertino.dart';

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

class ErrorResult<T> extends Result<T> {
  final String? description;
  final Map<String, String>? errors;

  ErrorResult({this.description, this.errors});
}