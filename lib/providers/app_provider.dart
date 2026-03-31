import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/sensor_data.dart';
import '../services/mqtt_service.dart';

class AppProvider extends ChangeNotifier {
  final MqttService _mqtt = MqttService();
  Timer? _sosTimer;   // SOS otomatik sıfırlama timer'ı

  String _brokerHost = '172.21.198.155';
  int _brokerPort = 1883;
  bool _isConnected = false;
  bool _isConnecting = false;
  bool _globalAlarm = false;
  bool _heatingOn = false;

  String get brokerHost => _brokerHost;
  int get brokerPort => _brokerPort;
  bool get isConnected => _isConnected;
  bool get isConnecting => _isConnecting;
  bool get globalAlarm => _globalAlarm;
  bool get heatingOn => _heatingOn;

  final List<AlertEvent> sosEvents = [];
  final List<AlertEvent> fallEvents = [];

  // ── YELEKler ──────────────────────────────────────────────
  List<Map<String, dynamic>> yelekler = List.generate(10, (i) => {
    'id': i + 1,
    'ip': i == 0 ? '172.21.198.155' : '—',
    'connected': false,
    'durum': 'unknown',
    'lastSeen': null,
  });

  final List<MpuChannel> mpuChannels = [
    MpuChannel(id: 'accel_x',  label: 'Accel X', unit: 'm/s²', min: -20,  max: 20),
    MpuChannel(id: 'accel_y',  label: 'Accel Y', unit: 'm/s²', min: -20,  max: 20),
    MpuChannel(id: 'accel_z',  label: 'Accel Z', unit: 'm/s²', min: -20,  max: 20),
    MpuChannel(id: 'gyro_x',   label: 'Gyro X',  unit: '°/s',  min: -360, max: 360),
    MpuChannel(id: 'gyro_y',   label: 'Gyro Y',  unit: '°/s',  min: -360, max: 360),
    MpuChannel(id: 'gyro_z',   label: 'Gyro Z',  unit: '°/s',  min: -360, max: 360),
    MpuChannel(id: 'mpu_temp', label: 'Temp',    unit: '°C',   min: -10,  max: 85),
  ];

  final List<SensorData> sensors = [
    SensorData(id: 'heart_rate', label: 'Nabız',            source: 'esp32_a', unit: 'bpm', min: 0,   max: 200,   safe: 100,  risk: 140),
    SensorData(id: 'spo2',       label: 'Kan Oksijen Oranı',source: 'esp32_a', unit: '%',   min: 85,  max: 100,   safe: 95,   risk: 92,  invert: true),
    SensorData(id: 'current_ma', label: 'Akım',             source: 'esp32_a', unit: 'mA',  min: 0,   max: 5000,  safe: 3000, risk: 4000),
    SensorData(id: 'power_mw',   label: 'Güç',              source: 'esp32_a', unit: 'mW',  min: 0,   max: 30000, safe: 20000,risk: 25000),
    SensorData(id: 'temp_ds18',  label: 'Sıcaklık 1',       source: 'esp32_c', unit: '°C',  min: 20,  max: 42,    safe: 37,   risk: 38.5),
    SensorData(id: 'black_gas',  label: 'Siyah Gaz',        source: 'esp32_c', unit: 'ppm', min: 0,   max: 500,   safe: 300,  risk: 400),
    SensorData(id: 'sht_temp',   label: 'Sıcaklık 2',       source: 'esp32_c', unit: '°C',  min: 20,  max: 42,    safe: 37,   risk: 38.5),
    SensorData(id: 'sht_hum',    label: 'Nem Oranı',        source: 'esp32_c', unit: '%',   min: 0,   max: 100,   safe: 70,   risk: 85),
    SensorData(id: 'co2_ppm',    label: 'CO2',              source: 'esp32_c', unit: 'ppm', min: 0,   max: 5000,  safe: 1000, risk: 2000),
    SensorData(id: 'impact_g',   label: 'Darbe Şiddeti',    source: 'esp32_d', unit: 'g',   min: 0,   max: 8,     safe: 2,    risk: 2.5),
    SensorData(id: 'co_ppm',     label: 'Karbonmonoksit',   source: 'esp32_c', unit: 'ppm', min: 0,   max: 1200,  safe: 500,  risk: 900),
  ];

  SensorData? getSensor(String id) {
    try { return sensors.firstWhere((s) => s.id == id); }
    catch (_) { return null; }
  }

  MpuChannel? getMpu(String id) {
    try { return mpuChannels.firstWhere((c) => c.id == id); }
    catch (_) { return null; }
  }

  Future<void> connect(String host, int port) async {
    _brokerHost = host;
    _brokerPort = port;
    _isConnecting = true;
    notifyListeners();

    final ok = await _mqtt.connect(
      host: host,
      port: port,
      onMessage: _handleMessage,
      onDisconnected: () {
        _isConnected = false;
        notifyListeners();
      },
    );

    _isConnected = ok;
    _isConnecting = false;

    // ── Yelek topic'lerine abone ol ──
    if (ok) {
      for (int i = 1; i <= 10; i++) {
        _mqtt.subscribe('yelek/$i/durum');
      }
      // SOS topic'ine abone ol
      _mqtt.subscribe('sensor/esp32_d/sos');
      // Düşme topic'ine abone ol
      _mqtt.subscribe('sensor/esp32_d/fall_out');
    }

    notifyListeners();
  }

  void disconnect() {
    _mqtt.disconnect();
    _isConnected = false;
    notifyListeners();
  }

  void _handleMessage(String topic, Map<String, dynamic> p) {
    // ── Yelek durum mesajları ──────────────────────────────
    if (topic.startsWith('yelek/') && topic.endsWith('/durum')) {
      final parts = topic.split('/');
      if (parts.length == 3) {
        final idx = int.tryParse(parts[1]);
        if (idx != null && idx >= 1 && idx <= 10) {
          yelekler[idx - 1]['connected'] = true;
          yelekler[idx - 1]['durum'] = p['durum']?.toString().toLowerCase().trim() ?? 'unknown';
          yelekler[idx - 1]['lastSeen'] = DateTime.now();
          notifyListeners();
        }
      }
      return;
    }

    // ── SOS projeden geliyor ───────────────────────────────
    if (topic == 'sensor/esp32_d/sos') {
      final state  = p['state'];
      final ip     = p['ip']?.toString()     ?? '—';
      final device = p['device']?.toString() ?? '—';

      if (state == 1 || state == true) {
        // SOS AÇIK → alarm ver
        _addSosEvent('🆘', 'SOS! $device ($ip)');
        _globalAlarm = true;
        notifyListeners();
      } else {
        // state: 0 → SOS KAPANDI, otomatik sıfırla
        _globalAlarm = false;
        notifyListeners();
      }
      return;
    }

    // ── Sensör mesajları ──────────────────────────────────
    if (topic == 'sensor/esp32_a/heartrate_oximeter') {
      if (p['heart_rate'] is num) {
        getSensor('heart_rate')?.updateValue((p['heart_rate'] as num).toDouble());
        if ((p['heart_rate'] as num) > 160) {
          _addSosEvent('⚠️', 'Nabız yüksek: ${p['heart_rate']} bpm');
          _triggerAlarm();
        }
      }
      if (p['spo2'] is num && (p['spo2'] as num) > 0) {
        getSensor('spo2')?.updateValue((p['spo2'] as num).toDouble());
        if ((p['spo2'] as num) < 90) {
          _addSosEvent('⚠️', 'KRİTİK Kan Oksijeni: ${p['spo2']}%');
          _triggerAlarm();
        }
      }
    }
    if (topic == 'sensor/esp32_a/ina169') {
      if (p['current_ma'] is num) getSensor('current_ma')?.updateValue((p['current_ma'] as num).toDouble());
      if (p['power_mw']   is num) getSensor('power_mw')?.updateValue((p['power_mw'] as num).toDouble());
    }
    if (topic == 'sensor/esp32_c/ds18b20') {
      if (p['temperature'] is num) getSensor('temp_ds18')?.updateValue((p['temperature'] as num).toDouble());
    }
    if (topic == 'sensor/esp32_c/black_gas') {
      if (p['gas_ppm'] is num) {
        getSensor('black_gas')?.updateValue((p['gas_ppm'] as num).toDouble());
        if ((p['gas_ppm'] as num) > 400) { _addSosEvent('⚠️', 'Siyah Gaz: ${p['gas_ppm']} ppm'); _triggerAlarm(); }
      }
    }
    if (topic == 'sensor/esp32_c/sht3x') {
      if (p['temperature'] is num) getSensor('sht_temp')?.updateValue((p['temperature'] as num).toDouble());
      if (p['humidity']    is num) getSensor('sht_hum')?.updateValue((p['humidity'] as num).toDouble());
    }
    if (topic == 'sensor/esp32_c/mhz14') {
      if (p['co2_ppm'] is num) {
        getSensor('co2_ppm')?.updateValue((p['co2_ppm'] as num).toDouble());
        if ((p['co2_ppm'] as num) > 2000) { _addSosEvent('⚠️', 'TEHLİKE CO2: ${p['co2_ppm']} ppm'); _triggerAlarm(); }
      }
    }
    if (topic == 'sensor/esp32_c/co') {
      if (p['co_ppm'] is num) {
        getSensor('co_ppm')?.updateValue((p['co_ppm'] as num).toDouble());
        if ((p['co_ppm'] as num) > 900) { _addSosEvent('⚠️', 'CO Tehlike: ${p['co_ppm']} ppm'); _triggerAlarm(); }
      }
    }
    if (topic == 'sensor/esp32_d/fall_out') {
      // impact_g String veya num olabilir → her ikisini de handle et
      final g = double.tryParse(p['impact_g']?.toString() ?? '0') ?? 0.0;
      final device = p['device']?.toString() ?? '—';
      final ip     = p['ip']?.toString()     ?? '—';
      getSensor('impact_g')?.updateValue(g);
      if (p['fall_detected'] == 1 || p['fall_detected'] == true || p['fall_detected'] == 'true') {
        final sev = g >= 4.0 ? 'Kritik' : g >= 2.5 ? 'Orta' : 'Hafif';
        _addFallEvent('⚠️', 'Düşme: ${g.toStringAsFixed(1)}g — $sev | $device ($ip)');
        _triggerAlarm();
      }
    }
    if (topic == 'sensor/esp32_d/mpu6050') {
      final ax = p['accel_x'] is num ? (p['accel_x'] as num).toDouble() : 0.0;
      final ay = p['accel_y'] is num ? (p['accel_y'] as num).toDouble() : 0.0;
      final az = p['accel_z'] is num ? (p['accel_z'] as num).toDouble() : 0.0;
      final gx = p['gyro_x']  is num ? (p['gyro_x']  as num).toDouble() : 0.0;
      final gy = p['gyro_y']  is num ? (p['gyro_y']  as num).toDouble() : 0.0;
      final gz = p['gyro_z']  is num ? (p['gyro_z']  as num).toDouble() : 0.0;
      final mt = p['temperature'] is num ? (p['temperature'] as num).toDouble() : null;
      getMpu('accel_x')?.value = ax;
      getMpu('accel_y')?.value = ay;
      getMpu('accel_z')?.value = az;
      getMpu('gyro_x')?.value  = gx;
      getMpu('gyro_y')?.value  = gy;
      getMpu('gyro_z')?.value  = gz;
      if (mt != null) getMpu('mpu_temp')?.value = mt;
    }
    if (topic == 'sensor/esp32_d/button1') {
      if (p['state'] == 1 || p['state'] == true) {
        _addSosEvent('🆘', 'SOS BUTONU BASILDI');
        _triggerAlarm();
      }
    }
    notifyListeners();
  }

  void _triggerAlarm() {
    _globalAlarm = true;
    notifyListeners();
  }

  void resetAlarm() {
    _globalAlarm = false;
    _mqtt.publish('dashboard/control', {'cmd': 'reset'});
    notifyListeners();
  }

  // ── Isıtma komutu — doğru topic: esp/remote_heating_control ──
  void sendHeatingCommand(bool state) {
    _heatingOn = state;
    // JSON payload: {"state": true} veya {"state": false}
    _mqtt.publishRaw('esp/remote_heating_control', state ? '1' : '0');
    notifyListeners();
  }

  void _addSosEvent(String icon, String msg) {
    sosEvents.insert(0, AlertEvent(icon: icon, message: msg, time: DateTime.now()));
    if (sosEvents.length > 50) sosEvents.removeLast();
  }

  void _addFallEvent(String icon, String msg) {
    fallEvents.insert(0, AlertEvent(icon: icon, message: msg, time: DateTime.now()));
    if (fallEvents.length > 50) fallEvents.removeLast();
  }
}