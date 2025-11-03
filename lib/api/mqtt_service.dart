import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttService {
  late MqttServerClient _client;
  final String _broker = '192.168.0.56';
  final int _port = 1883;

  MqttService._() {
    // Initialization code can go here if needed
  }

  static final MqttService _instance = MqttService._();

  factory MqttService() {
    return _instance;
  }

  MqttServerClient get client => _client;

  Future<bool> connect(String clientId, String username, String password) async {
    _client = MqttServerClient(_broker, clientId);
    _client.port = _port;
    _client.logging(on: true);

    _client.onConnected = _onConnected;
    _client.onDisconnected = _onDisconnected;
    _client.onUnsubscribed = _onUnsubscribed;
    _client.onSubscribed = _onSubscribed;
    _client.onSubscribeFail = _onSubscribeFail;
    _client.pongCallback = _pong;
    _client.keepAlivePeriod = 60;
    _client.setProtocolV311();

    final connMessage = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .withWillTopic('willtopic')
        .withWillMessage('My Will message')
        .startClean()
        .withWillQos(MqttQos.atLeastOnce)
        .authenticateAs(username, password);

    _client.connectionMessage = connMessage;

    try {
      await _client.connect();
      return _client.connectionStatus!.state == MqttConnectionState.connected;
    } on Exception catch (e) {
      debugPrint('MQTT_SERVICE::Client exception - $e');
      _client.disconnect();
      return false;
    }
  }

  void disconnect() {
    _client.disconnect();
  }

  void subscribe(String topic) {
    _client.subscribe(topic, MqttQos.atLeastOnce);
  }

  void publish(String topic, String message) {
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);
    _client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
  }

  void _onConnected() {
    debugPrint('MQTT_SERVICE::Connected');
  }

  void _onDisconnected() {
    debugPrint('MQTT_SERVICE::Disconnected');
  }

  void _onSubscribed(String topic) {
    debugPrint('MQTT_SERVICE::Subscribed to topic: $topic');
  }

  void _onSubscribeFail(String topic) {
    debugPrint('MQTT_SERVICE::Failed to subscribe to $topic');
  }

  void _onUnsubscribed(String? topic) {
    debugPrint('MQTT_SERVICE::Unsubscribed from topic: $topic');
  }

  void _pong() {
    debugPrint('MQTT_SERVICE::Ping response received');
  }
}