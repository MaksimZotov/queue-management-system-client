import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:queue_management_system_client/ui/router/router_page.dart';
import 'package:queue_management_system_client/ui/screens/board/board_screen.dart';
import 'package:queue_management_system_client/ui/screens/client/client_screen.dart';
import 'package:queue_management_system_client/ui/screens/queue/queues_screen.dart';
import 'package:queue_management_system_client/ui/screens/rights/rights_screen.dart';
import 'package:queue_management_system_client/ui/screens/account/authorization_screen.dart';
import 'package:queue_management_system_client/ui/screens/account/registration_screen.dart';
import 'package:queue_management_system_client/ui/screens/account/initial_screen.dart';
import 'package:queue_management_system_client/ui/screens/type/queue_types_screen.dart';

import '../screens/location/location_screen.dart';
import '../screens/location/locations_screen.dart';
import '../screens/queue/queue_screen.dart';
import '../screens/sequence/services_sequence_screen.dart';
import '../screens/service/services_screen.dart';

abstract class BaseConfig {
  Page getPage(ValueChanged<BaseConfig> emitConfig);

  BaseConfig? getPrevConfig() {
    return null;
  }
}

class ErrorConfig extends BaseConfig {
  @override
  Page getPage(ValueChanged<BaseConfig> emitConfig) {
    return const RouterPage(
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
    return RouterPage(
        key: const ValueKey('Initial Page'),
        child: InitialWidget(
          config: this,
          emitConfig: emitConfig,
        )
    );
  }
}

class AuthorizationConfig extends BaseConfig {
  @override
  Page getPage(ValueChanged<BaseConfig> emitConfig) {
    return RouterPage(
        key: const ValueKey('Authorization Page'),
        child: AuthorizationWidget(
          config: this,
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
    return RouterPage(
        key: const ValueKey('Registration Page'),
        child: RegistrationWidget(
          config: this,
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
    return RouterPage(
        key: ValueKey('Locations Page $username'),
        child: LocationsWidget(
          config: this,
          emitConfig: emitConfig,
        )
    );
  }
}

class LocationConfig extends BaseConfig {
  String username;
  int locationId;

  LocationConfig({
    required this.username,
    required this.locationId
  });

  @override
  Page getPage(ValueChanged<BaseConfig> emitConfig) {
    return RouterPage(
        key: ValueKey('Location Page $locationId'),
        child: LocationWidget(
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

class ServicesSequenceConfig extends BaseConfig {
  String username;
  int locationId;

  ServicesSequenceConfig({
    required this.username,
    required this.locationId
  });

  @override
  Page getPage(ValueChanged<BaseConfig> emitConfig) {
    return RouterPage(
        key: ValueKey('Services Sequence Page $locationId'),
        child: ServicesSequenceWidget(
          config: this,
          emitConfig: emitConfig,
        )
    );
  }

  @override
  BaseConfig getPrevConfig() {
    return LocationConfig(username: username, locationId: locationId);
  }
}

class ServicesConfig extends BaseConfig {
  String username;
  int locationId;

  ServicesConfig({
    required this.username,
    required this.locationId
  });

  @override
  Page getPage(ValueChanged<BaseConfig> emitConfig) {
    return RouterPage(
        key: ValueKey('Services Page $locationId'),
        child: ServicesWidget(
          config: this,
          emitConfig: emitConfig,
        )
    );
  }

  @override
  BaseConfig getPrevConfig() {
    return LocationConfig(username: username, locationId: locationId);
  }
}

class QueueTypesConfig extends BaseConfig {
  String username;
  int locationId;
  int? addedQueueTypeId;

  QueueTypesConfig({
    required this.username,
    required this.locationId
  });

  @override
  Page getPage(ValueChanged<BaseConfig> emitConfig) {
    return RouterPage(
        key: ValueKey('Queue Types Page $locationId $addedQueueTypeId'),
        child: QueueTypesWidget(
          config: this,
          emitConfig: emitConfig,
        )
    );
  }

  @override
  BaseConfig getPrevConfig() {
    return LocationConfig(username: username, locationId: locationId);
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
    return RouterPage(
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
    return RouterPage(
        key: ValueKey('Queue Page $queueId'),
        child: QueueWidget(
          config: this,
          emitConfig: emitConfig,
        )
    );
  }

  @override
  BaseConfig getPrevConfig() {
    return QueuesConfig(
        username: username,
        locationId: locationId
    );
  }
}

class ClientConfig extends BaseConfig {
  String username;
  int locationId;
  int clientId;
  String accessKey;

  ClientConfig({
    required this.username,
    required this.locationId,
    required this.clientId,
    required this.accessKey
  });

  @override
  Page getPage(ValueChanged<BaseConfig> emitConfig) {
    return RouterPage(
        key: ValueKey('Client Page $clientId $accessKey'),
        child: ClientWidget(
          config: this,
          emitConfig: emitConfig
        )
    );
  }

  @override
  BaseConfig? getPrevConfig() {
    return QueuesConfig(
        username: username,
        locationId: locationId
    );
  }
}

class BoardConfig extends BaseConfig {
  String username;
  int locationId;

  BoardConfig({
    required this.username,
    required this.locationId,
  });

  @override
  Page getPage(ValueChanged<BaseConfig> emitConfig) {
    return RouterPage(
        key: ValueKey('Board Page $locationId'),
        child: BoardWidget(
            config: this,
            emitConfig: emitConfig
        )
    );
  }

  @override
  BaseConfig? getPrevConfig() {
    return QueuesConfig(
        username: username,
        locationId: locationId
    );
  }
}

class RightsConfig extends BaseConfig {
  String username;
  int locationId;

  RightsConfig({
    required this.username,
    required this.locationId,
  });

  @override
  Page getPage(ValueChanged<BaseConfig> emitConfig) {
    return RouterPage(
        key: ValueKey('Rights Page $locationId'),
        child: RightsWidget(
            config: this,
            emitConfig: emitConfig
        )
    );
  }

  @override
  BaseConfig? getPrevConfig() {
    return QueuesConfig(
        username: username,
        locationId: locationId
    );
  }
}
