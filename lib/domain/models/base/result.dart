class Result<T> {
}

class SuccessResult<T> extends Result<T> {
  final T data;

  SuccessResult({required this.data});
}

class ErrorResult<T> extends Result<T> {
  final String? description;
  final Map<String, String>? errors;

  ErrorResult({required this.description, required this.errors});
}