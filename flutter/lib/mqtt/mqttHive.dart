import 'dart:io';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:rfircontrollerapp/main.dart';

enum MQTTAppConnectionState { connected, disconnected, connecting }

class MQTTManager {
  MQTTAppConnectionState _currentState = MQTTAppConnectionState.disconnected;
  MqttServerClient? _client;
  final String _identifier = 'android';
  final String _host = '192.168.1.97';
  final String _topic = 'topicToFlutter';

  MQTTAppConnectionState getCurrentState() {
    return _currentState;
  }

  void initializeMQTTClient() {
    _client = MqttServerClient(_host, _identifier);
    _client!.setProtocolV311();
    _client!.port = 1883;
    _client!.keepAlivePeriod = 60;
    _client!.onDisconnected = onDisconnected;
    _client!.logging(on: true);
    _client!.onConnected = onConnected;
    _client!.onSubscribed = onSubscribed;

    final MqttConnectMessage connMess = MqttConnectMessage()
        .withClientIdentifier(_identifier)
        .withWillTopic('willTopic')
        .withWillMessage('My Will message')
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);
    _client!.connectionMessage = connMess;
    print('Initialize::Mosquitto client connecting....');
  }

  void connect() async {
    try {
      await _client!.connect();
    } on NoConnectionException catch (e) {
      print('Connect::client exception - $e');
      disconnect();
    } on SocketException catch (e) {
      print('Connect::socket exception - $e');
      disconnect();
    }

    if (_client!.connectionStatus!.state == MqttConnectionState.connected) {
      print('Connect::Mosquitto client connected');
      _subscribeToTopic("topicIrToFlutter");
    } else {
      print(
          'Connect::ERROR Mosquitto client connection failed - disconnecting, status is ${_client!.connectionStatus}');
      disconnect();
    }
  }

  void disconnect() {
    print('Disconnect::Mosquitto client Disconnecting...');
    _client!.disconnect();
  }

  void publish(String message) {
    final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
    builder.addString(message);
    _client!.publishMessage(_topic, MqttQos.exactlyOnce, builder.payload!);
    print('Publish::The Message published');
  }

  void onSubscribed(String topic) {
    print('onSubscribed::Subscription confirmed for topic $topic');
  }

  void onDisconnected() {
    print(
        'onDisconnected::OnDisconnected client callback - Client disconnection');
    if (_client!.connectionStatus!.disconnectionOrigin ==
        MqttDisconnectionOrigin.solicited) {
      print(
          'onDisconnected::OnDisconnected callback is solicited, this is correct');
    } else {
      print(
          'onDisconnected::OnDisconnected callback is unsolicited or none, this is incorrect - exiting');
      print(_client!.connectionStatus!.disconnectionOrigin);
    }
  }

  void onConnected() {
    print('onConnected::Mosquitto client connected');
    //publish('test-message');
  }

  void _subscribeToTopic(String topicName) {
    print('Subscribing to the $topicName topic');
    _client!.subscribe(topicName, MqttQos.atMostOnce);

    // print the message when it is received
    _client!.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final recMess = c[0].payload as MqttPublishMessage;
      final pt =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

      print('YOU GOT A NEW MESSAGE:');
      print(pt);

      irCommandTextController.text = pt.toString();
    });
  }
}
