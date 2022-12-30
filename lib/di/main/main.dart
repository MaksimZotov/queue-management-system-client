import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'main.config.dart';

final getIt = GetIt.I;

@InjectableInit()
void setup() {
  $initGetIt(getIt);
}
