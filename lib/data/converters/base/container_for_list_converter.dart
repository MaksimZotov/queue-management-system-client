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

  ContainerForList<dynamic> fromJson({
    required Map<String, dynamic> json,
    required JsonConverter converter
  }) {
    List<dynamic> items = json[_containerForListFields.results];
    return ContainerForList(
      results: items.map((item) => converter.fromJson(item)).toList()
    );
  }
}