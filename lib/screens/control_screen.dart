import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class ControlScreen extends StatelessWidget {
  const ControlScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Isıtma Kontrolü
        _buildHeatingCard(app),
        const SizedBox(height: 16),

        // Bağlantı Bilgisi
        _buildInfoCard(app),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildHeatingCard(AppProvider app) {
    return Container(
      padding: const EdgeInsets.all(20),
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
              Icon(Icons.thermostat, color: Color(0xFFB45309), size: 22),
              SizedBox(width: 8),
              Text('Isıtma Kontrolü',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1C1C1E))),
            ],
          ),
          const SizedBox(height: 6),
          const Text('Ceket ısıtma sistemini kontrol edin',
            style: TextStyle(fontSize: 11, color: Colors.grey)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: app.isConnected && !app.heatingOn
                      ? () => app.sendHeatingCommand(true)
                      : null,
                  icon: const Icon(Icons.local_fire_department, size: 18),
                  label: const Text('Isıtmayı Aç'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB45309),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: app.isConnected && app.heatingOn
                      ? () => app.sendHeatingCommand(false)
                      : null,
                  icon: const Icon(Icons.ac_unit, size: 18),
                  label: const Text('Isıtmayı Kapat'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A3A6B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: app.heatingOn ? const Color(0xFFFFFBEB) : const Color(0xFFF2F2F7),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: app.heatingOn
                    ? const Color(0xFFB45309).withOpacity(0.3)
                    : Colors.grey.withOpacity(0.2),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  app.heatingOn ? Icons.local_fire_department : Icons.ac_unit,
                  size: 16,
                  color: app.heatingOn ? const Color(0xFFB45309) : Colors.grey,
                ),
                const SizedBox(width: 6),
                Text(
                  app.heatingOn ? 'Isıtma AKTİF 🔥' : 'Isıtma KAPALI ❄️',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: app.heatingOn ? const Color(0xFFB45309) : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(AppProvider app) {
    return Container(
      padding: const EdgeInsets.all(16),
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
              Icon(Icons.info_outline, color: Color(0xFF1A3A6B), size: 18),
              SizedBox(width: 6),
              Text('Bağlantı Bilgisi',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 12),
          _infoRow('Broker',  app.brokerHost),
          _infoRow('Port',    app.brokerPort.toString()),
          _infoRow('Durum',   app.isConnected ? '🟢 Bağlı' : '🔴 Bağlı Değil'),
          _infoRow('Alarm',   app.globalAlarm ? '🚨 Aktif' : '✅ Normal'),
          _infoRow('Isıtma',  app.heatingOn   ? '🔥 Açık'  : '❄️ Kapalı'),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text(value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, fontFamily: 'monospace')),
        ],
      ),
    );
  }
}