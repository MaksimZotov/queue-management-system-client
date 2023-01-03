import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:queue_management_system_client/ui/screens/client/client.dart';
import 'package:queue_management_system_client/ui/screens/queue/queues.dart';
import 'package:queue_management_system_client/ui/screens/verification/authorization.dart';
import 'package:queue_management_system_client/ui/screens/verification/registration.dart';
import 'package:queue_management_system_client/ui/screens/verification/select.dart';

import '../screens/location/locations.dart';
import '../screens/queue/queue.dart';

abstract class BaseConfig {
  Page getPage(ValueChanged<BaseConfig> emitConfig);

  BaseConfig? getPrevConfig() {
    return null;
  }
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

  @override
  BaseConfig getPrevConfig() {
    return InitialConfig();
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

  @override
  BaseConfig getPrevConfig() {
    return InitialConfig();
  }
}

class LocationsConfig extends BaseConfig {
  String username;

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
  String username;
  int locationId;

  QueuesConfig({
    required this.username,
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

  @override
  BaseConfig getPrevConfig() {
    return LocationsConfig(username: username);
  }
}

class QueueConfig extends BaseConfig {
  String username;
  int locationId;
  int queueId;

  QueueConfig({
    required this.username,
    required this.locationId,
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

  @override
  BaseConfig getPrevConfig() {
    return QueuesConfig(username: username, locationId: locationId);
  }
}

class ClientConfig extends BaseConfig {
  String username;
  int locationId;
  int queueId;

  ClientConfig({
    required this.username,
    required this.locationId,
    required this.queueId
  });

  @override
  Page getPage(ValueChanged<BaseConfig> emitConfig) {
    return MaterialPage(
        key: ValueKey('Client Page $queueId'),
        child: ClientWidget(
          config: this,
          emitConfig: emitConfig
        )
    );
  }

  @override
  BaseConfig? getPrevConfig() {
    return QueuesConfig(username: username, locationId: locationId);
  }
}
