import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../models/sensor_data.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildStatusCard(app),
        const SizedBox(height: 16),
        _buildAlertCard(
          title: 'SOS Olayları',
          icon: Icons.sos,
          iconBg: const Color(0xFFFDECEA),
          iconColor: const Color(0xFFC0392B),
          events: app.sosEvents,
          emptyMsg: 'Henüz SOS olayı yok',
          accentColor: const Color(0xFFC0392B),
        ),
        const SizedBox(height: 16),
        _buildAlertCard(
          title: 'Düşme Tespiti',
          icon: Icons.personal_injury,
          iconBg: const Color(0xFFFEF3E2),
          iconColor: const Color(0xFFB45309),
          events: app.fallEvents,
          emptyMsg: 'Henüz düşme olayı yok',
          accentColor: const Color(0xFFB45309),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildStatusCard(AppProvider app) {
    final totalEvents = app.sosEvents.length + app.fallEvents.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: app.globalAlarm ? const Color(0xFFFFF1F0) : const Color(0xFFF0FBF4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: app.globalAlarm
              ? const Color(0xFFC0392B).withOpacity(0.3)
              : const Color(0xFF1A7F4B).withOpacity(0.3),
        ),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)],
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: app.globalAlarm
                  ? const Color(0xFFC0392B).withOpacity(0.1)
                  : const Color(0xFF1A7F4B).withOpacity(0.1),
            ),
            child: Icon(
              app.globalAlarm ? Icons.warning_amber_rounded : Icons.check_circle,
              color: app.globalAlarm ? const Color(0xFFC0392B) : const Color(0xFF1A7F4B),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  app.globalAlarm ? 'SİSTEM ANORMAL' : 'SİSTEM NORMAL',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: app.globalAlarm ? const Color(0xFFC0392B) : const Color(0xFF1A7F4B),
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  app.globalAlarm
                      ? 'Toplam $totalEvents olay — kontrol edin!'
                      : 'Tüm sistemler normal çalışıyor',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
          if (app.globalAlarm)
            ElevatedButton(
              onPressed: () => app.resetAlarm(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC0392B),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Sıfırla', style: TextStyle(fontSize: 12)),
            ),
        ],
      ),
    );
  }

  Widget _buildAlertCard({
    required String title,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required List<AlertEvent> events,
    required String emptyMsg,
    required Color accentColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F2F7),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.1))),
            ),
            child: Row(
              children: [
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(8)),
                  child: Icon(icon, color: iconColor, size: 18),
                ),
                const SizedBox(width: 10),
                Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: events.isEmpty ? const Color(0xFFF0FBF4) : accentColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: events.isEmpty
                          ? const Color(0xFF1A7F4B).withOpacity(0.3)
                          : accentColor.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    events.isEmpty ? 'Normal' : '${events.length} Olay',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: events.isEmpty ? const Color(0xFF1A7F4B) : accentColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          events.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(Icons.check_circle_outline, color: Colors.grey.shade300, size: 32),
                      const SizedBox(height: 8),
                      Text(emptyMsg,
                        style: const TextStyle(
                            fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic)),
                    ],
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: events.length > 20 ? 20 : events.length,
                  separatorBuilder: (_, __) =>
                      Divider(height: 1, color: Colors.grey.withOpacity(0.08)),
                  itemBuilder: (_, i) {
                    final e = events[i];
                    return Container(
                      color: i == 0 ? accentColor.withOpacity(0.04) : null,
                      child: ListTile(
                        dense: true,
                        leading: Container(
                          width: 32, height: 32,
                          decoration: BoxDecoration(
                            color: i == 0
                                ? accentColor.withOpacity(0.1)
                                : Colors.grey.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(e.icon, style: const TextStyle(fontSize: 16)),
                          ),
                        ),
                        title: Text(
                          e.message,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: i == 0 ? FontWeight.w700 : FontWeight.w500,
                            color: i == 0 ? accentColor : const Color(0xFF1C1C1E),
                          ),
                        ),
                        trailing: Text(
                          DateFormat('HH:mm:ss').format(e.time),
                          style: TextStyle(
                            fontSize: 10,
                            color: i == 0 ? accentColor.withOpacity(0.7) : Colors.grey,
                            fontFamily: 'monospace',
                            fontWeight: i == 0 ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }
}