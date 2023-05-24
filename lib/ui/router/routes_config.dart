import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:queue_management_system_client/domain/enums/kiosk_mode.dart';
import 'package:queue_management_system_client/ui/router/router_page.dart';
import 'package:queue_management_system_client/ui/screens/board/board_screen.dart';
import 'package:queue_management_system_client/ui/screens/client/client_screen.dart';
import 'package:queue_management_system_client/ui/screens/queue/queues_screen.dart';
import 'package:queue_management_system_client/ui/screens/rights/rights_screen.dart';
import 'package:queue_management_system_client/ui/screens/account/authorization_screen.dart';
import 'package:queue_management_system_client/ui/screens/account/registration_screen.dart';
import 'package:queue_management_system_client/ui/screens/account/initial_screen.dart';

import '../screens/location/location_screen.dart';
import '../screens/location/locations_screen.dart';
import '../screens/queue/queue_screen.dart';
import '../screens/sequence/services_sequence_screen.dart';
import '../screens/service/services_screen.dart';
import '../screens/specialist/specialists_screen.dart';

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
      child: Material(
        child: Center(
          child: Text(
              '404',
              style: TextStyle(fontSize: 56)
          )
        )
      )
    );
  }
}

class InitialConfig extends BaseConfig {
  final bool firstLaunch;

  InitialConfig({
    required this.firstLaunch
  });

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
    return InitialConfig(firstLaunch: false);
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
    return InitialConfig(firstLaunch: false);
  }
}

class LocationsConfig extends BaseConfig {
  int accountId;

  LocationsConfig({
    required this.accountId
  });

  @override
  Page getPage(ValueChanged<BaseConfig> emitConfig) {
    return RouterPage(
        key: ValueKey('Locations Page $accountId'),
        child: LocationsWidget(
          config: this,
          emitConfig: emitConfig,
        )
    );
  }
}

class LocationConfig extends BaseConfig {
  int accountId;
  int locationId;
  String? kioskMode;
  bool? multipleSelect;

  LocationConfig({
    required this.accountId,
    required this.locationId,
    required this.kioskMode,
    required this.multipleSelect
  });

  @override
  Page getPage(ValueChanged<BaseConfig> emitConfig) {
    return RouterPage(
        key: ValueKey('Location Page $locationId $kioskMode $multipleSelect'),
        child: LocationWidget(
          config: this,
          emitConfig: emitConfig,
        )
    );
  }

  @override
  BaseConfig? getPrevConfig() {
    if (kioskMode == null) {
      return LocationsConfig(accountId: accountId);
    } else {
      return null;
    }
  }
}

class ServicesSequencesConfig extends BaseConfig {
  int accountId;
  int locationId;
  String? kioskMode;
  bool? multipleSelect;

  int? clientId;
  int? queueId;

  bool updateQueue;

  ServicesSequencesConfig({
    required this.accountId,
    required this.locationId,
    required this.kioskMode,
    required this.multipleSelect,

    required this.clientId,
    required this.queueId,

    this.updateQueue = false
  });

  @override
  Page getPage(ValueChanged<BaseConfig> emitConfig) {
    return RouterPage(
        key: ValueKey('Services Sequences Page $accountId $locationId $kioskMode $multipleSelect $clientId $queueId $updateQueue'),
        child: ServicesSequencesWidget(
          config: this,
          emitConfig: emitConfig,
        )
    );
  }

  @override
  BaseConfig? getPrevConfig() {
    if (clientId != null && queueId != null) {
      return QueueConfig(
          accountId: accountId,
          locationId: locationId,
          queueId: queueId!
      );
    } else if (kioskMode == null || kioskMode == KioskMode.all.name) {
      return LocationConfig(
          accountId: accountId,
          locationId: locationId,
          kioskMode: kioskMode,
          multipleSelect: multipleSelect
      );
    } else {
      return null;
    }
  }
}

class ServicesConfig extends BaseConfig {
  int accountId;
  int locationId;
  String? kioskMode;
  bool? multipleSelect;

  ServicesConfig({
    required this.accountId,
    required this.locationId,
    required this.kioskMode,
    required this.multipleSelect
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
  BaseConfig? getPrevConfig() {
    if (kioskMode == null || kioskMode == KioskMode.all.name) {
      return LocationConfig(
          accountId: accountId,
          locationId: locationId,
          kioskMode: kioskMode,
          multipleSelect: multipleSelect
      );
    } else {
      return null;
    }
  }
}

class SpecialistsConfig extends BaseConfig {
  int accountId;
  int locationId;
  String? kioskMode;
  bool? multipleSelect;

  SpecialistsConfig({
    required this.accountId,
    required this.locationId,
    required this.kioskMode,
    required this.multipleSelect
  });

  @override
  Page getPage(ValueChanged<BaseConfig> emitConfig) {
    return RouterPage(
        key: ValueKey('Queue Types Page $locationId'),
        child: SpecialistsWidget(
          config: this,
          emitConfig: emitConfig,
        )
    );
  }

  @override
  BaseConfig? getPrevConfig() {
    if (kioskMode == null || kioskMode == KioskMode.all.name) {
      return LocationConfig(
          accountId: accountId,
          locationId: locationId,
          kioskMode: kioskMode,
          multipleSelect: multipleSelect
      );
    } else {
      return null;
    }
  }
}

class QueuesConfig extends BaseConfig {
  int accountId;
  int locationId;

  QueuesConfig({
    required this.accountId,
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
    return LocationConfig(
        accountId: accountId,
        locationId: locationId,
        kioskMode: null,
        multipleSelect: null
    );
  }
}

class QueueConfig extends BaseConfig {
  int accountId;
  int locationId;
  int queueId;

  QueueConfig({
    required this.accountId,
    required this.locationId,
    required this.queueId
  });

  @override
  Page getPage(ValueChanged<BaseConfig> emitConfig) {
    return RouterPage(
        key: ValueKey('Queue Page $accountId $locationId $queueId'),
        child: QueueWidget(
          config: this,
          emitConfig: emitConfig,
        )
    );
  }

  @override
  BaseConfig getPrevConfig() {
    return QueuesConfig(
        accountId: accountId,
        locationId: locationId
    );
  }
}

class ClientConfig extends BaseConfig {
  int clientId;
  String accessKey;

  ClientConfig({
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
}

class BoardConfig extends BaseConfig {
  int accountId;
  int locationId;
  final int columnsAmount;
  final int rowsAmount;
  final int switchFrequency;

  BoardConfig({
    required this.accountId,
    required this.locationId,
    this.columnsAmount = 5,
    this.rowsAmount = 5,
    this.switchFrequency = 5
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
    return LocationConfig(
        accountId: accountId,
        locationId: locationId,
        kioskMode: null,
        multipleSelect: null
    );
  }
}

class RightsConfig extends BaseConfig {
  int accountId;
  int locationId;

  RightsConfig({
    required this.accountId,
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
    return LocationConfig(
        accountId: accountId,
        locationId: locationId,
        kioskMode: null,
        multipleSelect: null
    );
  }
}
