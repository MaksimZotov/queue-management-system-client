abstract class JsonConverter<T> {
  T fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson(T data);
}

typedef FromJson<T> = T Function(Map<String, dynamic> json);