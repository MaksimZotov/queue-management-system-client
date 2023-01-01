import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:queue_management_system_client/ui/screens/queue/queues.dart';
import 'package:queue_management_system_client/ui/screens/verification/authorization.dart';
import 'package:queue_management_system_client/ui/screens/verification/registration.dart';
import 'package:queue_management_system_client/ui/screens/verification/select.dart';

import '../screens/location/locations.dart';
import '../screens/queue/queue.dart';

abstract class BaseConfig {
  Page getPage(ValueChanged<BaseConfig> emitConfig);
}

class ErrorConfig extends BaseConfig {
  @override
  Page getPage(ValueChanged<BaseConfig> emitConfig) {
    return const MaterialPage(
      key: ValueKey('Error Page'),
      child: Center(
        child: Text('404'),
      )
    );
  }
}

class InitialConfig extends BaseConfig {
  @override
  Page getPage(ValueChanged<BaseConfig> emitConfig) {
    return MaterialPage(
        key: const ValueKey('Initial Page'),
        child: SelectWidget(
          emitConfig: emitConfig,
        )
    );
  }
}

class AuthorizationConfig extends BaseConfig {
  @override
  Page getPage(ValueChanged<BaseConfig> emitConfig) {
    return MaterialPage(
        key: const ValueKey('Authorization Page'),
        child: AuthorizationWidget(
          emitConfig: emitConfig,
        )
    );
  }
}

class RegistrationConfig extends BaseConfig {
  @override
  Page getPage(ValueChanged<BaseConfig> emitConfig) {
    return MaterialPage(
        key: const ValueKey('Registration Page'),
        child: RegistrationWidget(
          emitConfig: emitConfig,
        )
    );
  }
}

class LocationsConfig extends BaseConfig {
  String? username;

  LocationsConfig({
    required this.username
  });

  @override
  Page getPage(ValueChanged<BaseConfig> emitConfig) {
    return MaterialPage(
        key: ValueKey('Locations Page $username'),
        child: LocationsWidget(
          config: this,
          emitConfig: emitConfig,
        )
    );
  }
}

class QueuesConfig extends BaseConfig {
  int locationId;

  QueuesConfig({
    required this.locationId
  });

  @override
  Page getPage(ValueChanged<BaseConfig> emitConfig) {
    return MaterialPage(
        key: ValueKey('Queues Page $locationId'),
        child: QueuesWidget(
          config: this,
          emitConfig: emitConfig,
        )
    );
  }
}

class QueueConfig extends BaseConfig {
  int queueId;

  QueueConfig({
    required this.queueId
  });

  @override
  Page getPage(ValueChanged<BaseConfig> emitConfig) {
    return MaterialPage(
        key: ValueKey('Queue Page $queueId'),
        child: QueueWidget(
          config: this,
        )
    );
  }
}
