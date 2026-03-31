import 'dart:convert';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttService {
  MqttServerClient? _client;
  bool _connected = false;

  bool get isConnected => _connected;

  final List<String> topics = [
    'sensor/esp32_a/heartrate_oximeter',
    'sensor/esp32_a/ina169',
    'sensor/esp32_c/ds18b20',
    'sensor/esp32_c/black_gas',
    'sensor/esp32_c/sht3x',
    'sensor/esp32_c/mhz14',
    'sensor/esp32_d/fall_out',
    'sensor/esp32_d/mpu6050',
    'sensor/esp32_d/adxl335',
    'sensor/esp32_d/button1',
    'sensor/esp32_d/mq4',
    'sensor/esp32_c/co',
    'sensor/esp32_d/sos',
  ];

  Future<bool> connect({
    required String host,
    required int port,
    required Function(String topic, Map<String, dynamic> payload) onMessage,
    required Function() onDisconnected,
  }) async {
    try {
      _client = MqttServerClient(host, 'flutter_${DateTime.now().millisecondsSinceEpoch}');
      _client!.port = port;
      _client!.keepAlivePeriod = 30;
      _client!.logging(on: false);
      _client!.onDisconnected = () {
        _connected = false;
        onDisconnected();
      };

      final connMessage = MqttConnectMessage()
          .withClientIdentifier('flutter_akilli_${DateTime.now().millisecondsSinceEpoch}')
          .startClean()
          .withWillQos(MqttQos.atLeastOnce);
      _client!.connectionMessage = connMessage;

      await _client!.connect();

      if (_client!.connectionStatus!.state == MqttConnectionState.connected) {
        _connected = true;

        // Varsayılan sensör topic'lerine abone ol
        for (final topic in topics) {
          _client!.subscribe(topic, MqttQos.atLeastOnce);
        }

        // Mesajları dinle
        _client!.updates!.listen((List<MqttReceivedMessage<MqttMessage>> messages) {
          for (final msg in messages) {
            final recMsg = msg.payload as MqttPublishMessage;
            final rawPayload = MqttPublishPayload.bytesToStringAsString(
                recMsg.payload.message).trim();

            Map<String, dynamic> data;
            try {
              // JSON olarak parse etmeyi dene
              data = jsonDecode(rawPayload) as Map<String, dynamic>;
            } catch (_) {
              // JSON değilse → düz string olarak wrap et
              // "sos", "1", "true", "normal", "anormal" gibi değerler için
              final lower = rawPayload.toLowerCase();
              if (lower == 'sos' || lower == '1' || lower == 'true' || lower == 'alarm') {
                data = {'state': 1, 'sos': true};
              } else {
                data = {'durum': rawPayload, 'value': rawPayload};
              }
            }

            onMessage(msg.topic, data);
          }
        });
        return true;
      }
      return false;
    } catch (e) {
      _connected = false;
      return false;
    }
  }

  // ── Yeni topic'e abone ol ────────────────────────────────
  void subscribe(String topic) {
    if (!_connected || _client == null) return;
    _client!.subscribe(topic, MqttQos.atLeastOnce);
  }

  void publish(String topic, Map<String, dynamic> payload) {
    if (!_connected || _client == null) return;
    final builder = MqttClientPayloadBuilder();
    builder.addString(jsonEncode(payload));
    _client!.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
  }

  // Düz string (JSON değil) yayınla — örn: "1" veya "0"
  void publishRaw(String topic, String payload) {
    if (!_connected || _client == null) return;
    final builder = MqttClientPayloadBuilder();
    builder.addString(payload);
    _client!.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
  }

  void disconnect() {
    _client?.disconnect();
    _connected = false;
  }
}