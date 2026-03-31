import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../providers/app_provider.dart';
import '../models/sensor_data.dart';

class SensorsScreen extends StatelessWidget {
  const SensorsScreen({super.key});

  static const List<Map<String, dynamic>> _sensorDefs = [
    // KALP & OKSİJEN
    {'id': 'heart_rate', 'label': 'Nabız',                'unit': 'bpm', 'min': 0.0,  'max': 200.0,  'safe': 100.0, 'risk': 140.0, 'invert': false, 'group': 'Kalp & Oksijen'},
    {'id': 'spo2',       'label': 'Kan Oksijen Oranı',    'unit': '%',   'min': 85.0, 'max': 100.0,  'safe': 95.0,  'risk': 92.0,  'invert': true,  'group': 'Kalp & Oksijen'},
    // ENERJİ
    {'id': 'current_ma', 'label': 'Akım',                 'unit': 'mA',  'min': 0.0,  'max': 5000.0, 'safe': 3000.0,'risk': 4000.0,'invert': false, 'group': 'Enerji'},
    {'id': 'power_mw',   'label': 'Güç',                  'unit': 'mW',  'min': 0.0,  'max': 30000.0,'safe': 20000.0,'risk':25000.0,'invert': false, 'group': 'Enerji'},
    // SICAKLIK & ÇEVRE
    {'id': 'temp_ds18',  'label': 'Sıcaklık 1',           'unit': '°C',  'min': 20.0, 'max': 42.0,   'safe': 37.0,  'risk': 38.5,  'invert': false, 'group': 'Sıcaklık & Çevre'},
    {'id': 'sht_temp',   'label': 'Sıcaklık 2',           'unit': '°C',  'min': 20.0, 'max': 42.0,   'safe': 37.0,  'risk': 38.5,  'invert': false, 'group': 'Sıcaklık & Çevre'},
    {'id': 'sht_hum',    'label': 'Nem Oranı',            'unit': '%',   'min': 0.0,  'max': 100.0,  'safe': 70.0,  'risk': 85.0,  'invert': false, 'group': 'Sıcaklık & Çevre'},
    {'id': 'co2_ppm',    'label': 'CO2',                  'unit': 'ppm', 'min': 0.0,  'max': 5000.0, 'safe': 1000.0,'risk': 2000.0,'invert': false, 'group': 'Sıcaklık & Çevre'},
    {'id': 'black_gas',  'label': 'Siyah Gaz',            'unit': 'ppm', 'min': 0.0,  'max': 500.0,  'safe': 300.0, 'risk': 400.0, 'invert': false, 'group': 'Sıcaklık & Çevre'},
    // GAZ  (MQ-4 kaldırıldı)
    {'id': 'co_ppm',     'label': 'Karbonmonoksit (CO)',  'unit': 'ppm', 'min': 0.0,  'max': 1200.0, 'safe': 500.0, 'risk': 900.0, 'invert': false, 'group': 'Gaz Sensörleri'},
    // DARBE
    {'id': 'impact_g',   'label': 'Darbe Şiddeti',        'unit': 'g',   'min': 0.0,  'max': 8.0,    'safe': 2.0,   'risk': 2.5,   'invert': false, 'group': 'Hareket & Darbe'},
  ];

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();

    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (final def in _sensorDefs) {
      final group = def['group'] as String;
      grouped.putIfAbsent(group, () => []);
      grouped[group]!.add(def);
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildConnectCard(context, app),
        const SizedBox(height: 16),
        ...grouped.entries.map((e) => _buildGroup(e.key, e.value, app)),
        _buildMPUCard(app),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildConnectCard(BuildContext context, AppProvider app) {
    final hostController = TextEditingController(text: app.brokerHost);
    final portController = TextEditingController(text: app.brokerPort.toString());

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('MQTT Bağlantısı',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1A3A6B))),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextField(
                  controller: hostController,
                  decoration: _inputDec('Broker IP'),
                  style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: portController,
                  decoration: _inputDec('Port'),
                  keyboardType: TextInputType.number,
                  style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: app.isConnecting
                      ? null
                      : () => app.connect(
                          hostController.text,
                          int.tryParse(portController.text) ?? 1883),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A3A6B),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(app.isConnecting ? 'Bağlanıyor...' : 'Bağlan'),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: app.isConnected ? () => app.disconnect() : null,
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Kes'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDec(String label) => InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 11),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        isDense: true,
      );

  Widget _buildGroup(String name, List<Map<String, dynamic>> defs, AppProvider app) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            name.toUpperCase(),
            style: const TextStyle(
                fontSize: 10, fontWeight: FontWeight.w700, color: Colors.grey, letterSpacing: 1.2),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.95,
          ),
          itemCount: defs.length,
          itemBuilder: (_, i) {
            final def = defs[i];
            final sensor = app.getSensor(def['id'] as String);
            return _buildGaugeCard(
              label:  def['label'] as String,
              unit:   def['unit'] as String,
              value:  sensor?.value,
              min:    def['min'] as double,
              max:    def['max'] as double,
              safe:   def['safe'] as double,
              risk:   def['risk'] as double,
              invert: def['invert'] as bool,
            );
          },
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildGaugeCard({
    required String label,
    required String unit,
    required double? value,
    required double min,
    required double max,
    required double safe,
    required double risk,
    required bool invert,
  }) {
    String status = 'nodata';
    Color statusColor = Colors.grey.shade300;
    Color statusTextColor = Colors.grey;
    String statusText = '—';

    if (value != null) {
      if (invert) {
        if (value >= safe)      status = 'normal';
        else if (value >= risk) status = 'risk';
        else                    status = 'critical';
      } else {
        if (value <= safe)      status = 'normal';
        else if (value <= risk) status = 'risk';
        else                    status = 'critical';
      }
      switch (status) {
        case 'normal':
          statusColor     = const Color(0xFF22C55E);
          statusTextColor = const Color(0xFF15803D);
          statusText      = 'Normal';
          break;
        case 'risk':
          statusColor     = const Color(0xFFF59E0B);
          statusTextColor = const Color(0xFFB45309);
          statusText      = 'Riskli';
          break;
        case 'critical':
          statusColor     = const Color(0xFFEF4444);
          statusTextColor = const Color(0xFFB91C1C);
          statusText      = 'Kritik';
          break;
      }
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 12, 10, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: value != null ? statusColor.withOpacity(0.25) : Colors.grey.withOpacity(0.1),
        ),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF1C1C1E)),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: 90,
            child: _RadialGauge(value: value, min: min, max: max, color: statusColor, unit: unit),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: value != null ? statusColor.withOpacity(0.1) : Colors.grey.withOpacity(0.05),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: value != null ? statusColor.withOpacity(0.3) : Colors.grey.withOpacity(0.15),
              ),
            ),
            child: Text(
              value != null ? statusText : 'Veri Yok',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: value != null ? statusTextColor : Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMPUCard(AppProvider app) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.sensors, size: 16, color: Color(0xFF1A3A6B)),
              SizedBox(width: 6),
              Text('MPU-6050 IMU',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1A3A6B))),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: app.mpuChannels
                .map((ch) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                          color: const Color(0xFFF2F2F7), borderRadius: BorderRadius.circular(10)),
                      child: Column(
                        children: [
                          Text(
                            ch.value != null ? ch.value!.toStringAsFixed(2) : '—',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1A3A6B)),
                          ),
                          Text('${ch.label}\n${ch.unit}',
                              style: const TextStyle(fontSize: 9, color: Colors.grey),
                              textAlign: TextAlign.center),
                        ],
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  RADİAL GAUGE
// ════════════════════════════════════════════════════════════
class _RadialGauge extends StatelessWidget {
  final double? value;
  final double min;
  final double max;
  final Color color;
  final String unit;

  const _RadialGauge({
    required this.value,
    required this.min,
    required this.max,
    required this.color,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GaugePainter(value: value, min: min, max: max, color: color),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value != null ? _fmt(value!) : '—',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: value != null ? color : Colors.grey.shade300,
                  height: 1,
                ),
              ),
              Text(unit,
                  style: TextStyle(fontSize: 9, color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }

  String _fmt(double v) {
    if (v >= 10000) return '${(v / 1000).toStringAsFixed(1)}k';
    if (v >= 1000)  return v.toStringAsFixed(0);
    if (v < 10)     return v.toStringAsFixed(1);
    return v.toStringAsFixed(0);
  }
}

class _GaugePainter extends CustomPainter {
  final double? value;
  final double min;
  final double max;
  final Color color;

  const _GaugePainter({required this.value, required this.min, required this.max, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.62;
    final radius = math.min(size.width, size.height) * 0.42;
    const startAngle = math.pi * 0.75;
    const sweepAngle = math.pi * 1.5;

    // Track
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: radius),
      startAngle, sweepAngle, false,
      Paint()..color = Colors.grey.shade100..strokeWidth = 10..style = PaintingStyle.stroke..strokeCap = StrokeCap.round,
    );

    if (value != null) {
      final pct = ((value! - min) / (max - min)).clamp(0.0, 1.0);

      // Gradient arc
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: radius),
        startAngle, sweepAngle * pct, false,
        Paint()
          ..shader = SweepGradient(
            center: Alignment.center,
            startAngle: startAngle,
            endAngle: startAngle + sweepAngle,
            colors: const [Color(0xFF22C55E), Color(0xFFF59E0B), Color(0xFFEF4444)],
            stops: const [0.0, 0.55, 1.0],
          ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: radius))
          ..strokeWidth = 10..style = PaintingStyle.stroke..strokeCap = StrokeCap.round,
      );

      // Tick marks
      for (int i = 0; i <= 10; i++) {
        final angle = startAngle + sweepAngle * (i / 10);
        final isMajor = i % 5 == 0;
        canvas.drawLine(
          Offset(cx + (radius - (isMajor ? 14 : 9)) * math.cos(angle), cy + (radius - (isMajor ? 14 : 9)) * math.sin(angle)),
          Offset(cx + (radius - 2) * math.cos(angle), cy + (radius - 2) * math.sin(angle)),
          Paint()..color = Colors.grey.shade200..strokeWidth = isMajor ? 2.0 : 1.5..strokeCap = StrokeCap.round,
        );
      }

      // Needle
      final needleAngle = startAngle + sweepAngle * pct;
      canvas.drawLine(
        Offset(cx, cy),
        Offset(cx + (radius - 16) * math.cos(needleAngle), cy + (radius - 16) * math.sin(needleAngle)),
        Paint()..color = color..strokeWidth = 2.5..strokeCap = StrokeCap.round,
      );
      canvas.drawCircle(Offset(cx, cy), 5, Paint()..color = color);
      canvas.drawCircle(Offset(cx, cy), 3, Paint()..color = Colors.white);
    } else {
      canvas.drawLine(
        Offset(cx, cy),
        Offset(cx + (radius - 16) * math.cos(startAngle), cy + (radius - 16) * math.sin(startAngle)),
        Paint()..color = Colors.grey.shade300..strokeWidth = 2..strokeCap = StrokeCap.round,
      );
      canvas.drawCircle(Offset(cx, cy), 5, Paint()..color = Colors.grey.shade300);
      canvas.drawCircle(Offset(cx, cy), 3, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(_GaugePainter old) => old.value != value || old.color != color;
}