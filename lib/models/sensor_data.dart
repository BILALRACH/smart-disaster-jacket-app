class SensorData {
  final String id;
  final String label;
  final String source;
  final String unit;
  final double min;
  final double max;
  final double safe;
  final double risk;
  final bool invert;
  double? value;
  DateTime? lastUpdate;
  List<double> history;

  SensorData({
    required this.id,
    required this.label,
    required this.source,
    required this.unit,
    required this.min,
    required this.max,
    required this.safe,
    required this.risk,
    this.invert = false,
    this.value,
    this.lastUpdate,
    List<double>? history,
  }) : history = history ?? [];

  void updateValue(double v) {
    value = v;
    lastUpdate = DateTime.now();
    history.add(v);
    if (history.length > 60) history.removeAt(0);
  }

  String get status {
    if (value == null) return 'unknown';
    if (invert) {
      if (value! >= safe) return 'normal';
      if (value! >= risk) return 'risk';
      return 'critical';
    } else {
      if (value! <= safe) return 'normal';
      if (value! <= risk) return 'risk';
      return 'critical';
    }
  }
}

class AlertEvent {
  final String icon;
  final String message;
  final DateTime time;
  AlertEvent({
    required this.icon,
    required this.message,
    required this.time,
  });
}

class MpuChannel {
  final String id;
  final String label;
  final String unit;
  final double min;
  final double max;
  double? value;
  MpuChannel({
    required this.id,
    required this.label,
    required this.unit,
    required this.min,
    required this.max,
    this.value,
  });
}