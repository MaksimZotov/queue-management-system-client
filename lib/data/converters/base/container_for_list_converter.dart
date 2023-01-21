import 'package:injectable/injectable.dart';

import '../../../domain/models/base/container_for_list.dart';
import '../json_converter.dart';

@singleton
class ContainerForListFields {
  final String results = 'results';
}

@singleton
class ContainerForListConverter {
  final ContainerForListFields _containerForListFields;
  ContainerForListConverter(this._containerForListFields);

  ContainerForList<T> fromJson<T>({
    required Map<String, dynamic> json,
    required FromJson<T> fromJson
  }) {
    List items = json[_containerForListFields.results];
    return ContainerForList<T>(
      results: items.map((item) => fromJson(item)).toList()
    );
  }
}