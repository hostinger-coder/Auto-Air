import 'package:flutter/foundation.dart';

enum DeviceStatus { online, offline, updating }

class WifiConfig {
  final String? ssid;
  final String? password;
  final bool isStatic;
  final String? ipAddress;
  final String? gateway;
  final String? subnet;

  WifiConfig({
    this.ssid,
    this.password,
    this.isStatic = false,
    this.ipAddress,
    this.gateway,
    this.subnet,
  });

  factory WifiConfig.fromJson(Map<String, dynamic> json) {
    return WifiConfig(
      ssid: json['ssid'],
      password: json['password'],
      isStatic: json['is_static'] ?? false,
      ipAddress: json['ip_address'],
      gateway: json['gateway'],
      subnet: json['subnet'],
    );
  }
}

class MqttConfig {
  final String? host;
  final int? port;
  final String? clientId;
  final String? authUsername;
  final String? authPassword;

  MqttConfig({
    this.host,
    this.port,
    this.clientId,
    this.authUsername,
    this.authPassword,
  });

  factory MqttConfig.fromJson(Map<String, dynamic> json) {
    return MqttConfig(
      host: json['host'],
      port: json['port'],
      clientId: json['client_id'],
      authUsername: json['auth_username'],
      authPassword: json['auth_password'],
    );
  }
}

class TimeConfig {
  final String? ntpServer;
  final String? timezone;

  TimeConfig({this.ntpServer, this.timezone});

  factory TimeConfig.fromJson(Map<String, dynamic> json) {
    return TimeConfig(
      ntpServer: json['ntp_server'],
      timezone: json['timezone'],
    );
  }
}

class FanConfig {
  final String? mode;
  final bool isOn;
  final int? minTemp;
  final int? maxTemp;

  FanConfig({this.mode, this.isOn = false, this.minTemp, this.maxTemp});

  factory FanConfig.fromJson(Map<String, dynamic> json) {
    return FanConfig(
      mode: json['mode'],
      isOn: json['is_on'] ?? false,
      minTemp: json['min_temp'],
      maxTemp: json['max_temp'],
    );
  }
}

class DeviceConfig {
  final WifiConfig wifi;
  final MqttConfig mqtt;
  final TimeConfig time;
  final FanConfig fan;

  DeviceConfig({
    required this.wifi,
    required this.mqtt,
    required this.time,
    required this.fan,
  });

  factory DeviceConfig.fromJson(Map<String, dynamic> json) {
    return DeviceConfig(
      wifi: WifiConfig.fromJson(json['wifi'] ?? {}),
      mqtt: MqttConfig.fromJson(json['mqtt'] ?? {}),
      time: TimeConfig.fromJson(json['time'] ?? {}),
      fan: FanConfig.fromJson(json['fan'] ?? {}),
    );
  }
}

class Device {
  final String id;
  final String name;
  final String serialNumber;
  final String? description;
  final DeviceStatus status;
  final DeviceConfig config;

  Device({
    required this.id,
    required this.name,
    required this.serialNumber,
    required this.status,
    required this.config,
    this.description,
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      id: json['id']?.toString() ?? 'N/A',
      name: json['name'] ?? 'Unnamed Device',
      serialNumber: json['serial_number'] ?? 'N/A',
      description: json['description'],
      status: _parseStatus(json['status']),
      config: DeviceConfig.fromJson(json['config'] ?? {}),
    );
  }

  static DeviceStatus _parseStatus(dynamic statusValue) {
    if (statusValue is bool) {
      return statusValue ? DeviceStatus.online : DeviceStatus.offline;
    }
    if (statusValue is String) {
      switch (statusValue.toLowerCase()) {
        case 'online':
          return DeviceStatus.online;
        case 'updating':
          return DeviceStatus.updating;
        default:
          return DeviceStatus.offline;
      }
    }
    return DeviceStatus.offline;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Device &&
              runtimeType == other.runtimeType &&
              id == other.id &&
              serialNumber == other.serialNumber;

  @override
  int get hashCode => id.hashCode ^ serialNumber.hashCode;

  @override
  String toString() {
    return 'Device{id: $id, name: $name, serialNumber: $serialNumber}';
  }
}