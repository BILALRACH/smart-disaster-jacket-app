import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class YelekScreen extends StatelessWidget {
  const YelekScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildHeaderCard(app),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
          ),
          itemCount: 10,
          itemBuilder: (_, i) => _buildYelekCard(context, i + 1, app),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildHeaderCard(AppProvider app) {
    final aktif = app.yelekler.where((y) => y['connected'] == true).length;
    final anormal = app.yelekler.where((y) => y['connected'] == true && y['durum'] == 'anormal').length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A3A6B), Color(0xFF1D4ED8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: const Color(0xFF1A3A6B).withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.shield, color: Colors.white, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Yelek Ağı', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
                const SizedBox(height: 4),
                Text(
                  '$aktif / 10 yelek bağlı${anormal > 0 ? ' • $anormal anormal' : ''}',
                  style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.75)),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: anormal > 0 ? const Color(0xFFEF4444).withOpacity(0.25) : Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: anormal > 0 ? const Color(0xFFEF4444).withOpacity(0.5) : Colors.white.withOpacity(0.2),
              ),
            ),
            child: Text(
              anormal > 0 ? '⚠️ $anormal Anormal' : '$aktif Aktif',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYelekCard(BuildContext context, int index, AppProvider app) {
    final yelek = index <= app.yelekler.length ? app.yelekler[index - 1] : null;
    final bool connected = yelek?['connected'] == true;
    final String durum = yelek?['durum'] ?? 'unknown';
    final String ip = yelek?['ip'] ?? '—';

    final Color cardBg;
    final Color borderColor;
    final Color dotColor;
    final Color titleColor;
    final Color ipColor;
    final Color badgeBg;
    final Color badgeText;
    final Color badgeBorder;
    final String statusText;
    final IconData statusIcon;

    if (!connected) {
      cardBg      = const Color(0xFFF9FAFB);
      borderColor = const Color(0xFFE5E7EB);
      dotColor    = const Color(0xFFD1D5DB);
      titleColor  = const Color(0xFFD1D5DB);
      ipColor     = const Color(0xFFE5E7EB);
      badgeBg     = const Color(0xFFF3F4F6);
      badgeText   = const Color(0xFF9CA3AF);
      badgeBorder = const Color(0xFFE5E7EB);
      statusText  = 'Bağlı Değil';
      statusIcon  = Icons.link_off_rounded;
    } else if (durum == 'normal') {
      cardBg      = const Color(0xFFF0FDF4);
      borderColor = const Color(0xFF86EFAC);
      dotColor    = const Color(0xFF22C55E);
      titleColor  = const Color(0xFF15803D);
      ipColor     = const Color(0xFF6B7280);
      badgeBg     = const Color(0xFFDCFCE7);
      badgeText   = const Color(0xFF15803D);
      badgeBorder = const Color(0xFF86EFAC);
      statusText  = 'Normal';
      statusIcon  = Icons.check_circle_rounded;
    } else if (durum == 'anormal') {
      cardBg      = const Color(0xFFFFF1F2);
      borderColor = const Color(0xFFFCA5A5);
      dotColor    = const Color(0xFFEF4444);
      titleColor  = const Color(0xFFB91C1C);
      ipColor     = const Color(0xFF6B7280);
      badgeBg     = const Color(0xFFFEE2E2);
      badgeText   = const Color(0xFFB91C1C);
      badgeBorder = const Color(0xFFFCA5A5);
      statusText  = 'Anormal';
      statusIcon  = Icons.warning_rounded;
    } else {
      cardBg      = const Color(0xFFF9FAFB);
      borderColor = const Color(0xFFE5E7EB);
      dotColor    = const Color(0xFFD1D5DB);
      titleColor  = const Color(0xFF9CA3AF);
      ipColor     = const Color(0xFFD1D5DB);
      badgeBg     = const Color(0xFFF3F4F6);
      badgeText   = const Color(0xFF9CA3AF);
      badgeBorder = const Color(0xFFE5E7EB);
      statusText  = 'Bekleniyor';
      statusIcon  = Icons.hourglass_empty_rounded;
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => YelekDetailScreen(
              index: index,
              yelek: yelek ?? {},
              app: app,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: connected ? 1.5 : 1.0),
          boxShadow: [
            BoxShadow(
              color: connected ? dotColor.withOpacity(0.12) : Colors.black.withOpacity(0.03),
              blurRadius: connected ? 10 : 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Yelek $index',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: titleColor),
                ),
                connected
                    ? _PulsingDot(color: dotColor)
                    : Container(
                        width: 10, height: 10,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: dotColor),
                      ),
              ],
            ),
            Text(ip, style: TextStyle(fontSize: 10, fontFamily: 'monospace', color: ipColor)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: badgeBg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: badgeBorder),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(statusIcon, size: 12, color: badgeText),
                  const SizedBox(width: 4),
                  Text(statusText, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: badgeText)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  YELEK DETAY SAYFASI
// ════════════════════════════════════════════════════════════
class YelekDetailScreen extends StatelessWidget {
  final int index;
  final Map<String, dynamic> yelek;
  final AppProvider app;

  const YelekDetailScreen({
    super.key,
    required this.index,
    required this.yelek,
    required this.app,
  });

  @override
  Widget build(BuildContext context) {
    final bool connected    = yelek['connected'] == true;
    final String durum      = yelek['durum'] ?? 'unknown';
    final String ip         = yelek['ip'] ?? '—';
    final DateTime? lastSeen = yelek['lastSeen'] as DateTime?;
    final bool isAnormal    = durum == 'anormal';

    // ── Sensörleri normal / anormal olarak ayır ──────────
    final List<Map<String, dynamic>> anormalSensors = [];
    final List<Map<String, dynamic>> normalSensors  = [];

    for (final s in app.sensors) {
      if (s.value == null) continue;

      // Düşme → fall detection'dan bakılır
      if (s.id == 'impact_g') {
        final bool fallDetected = app.fallEvents.isNotEmpty &&
            DateTime.now().difference(app.fallEvents.first.time).inSeconds < 60;
        if (fallDetected) {
          anormalSensors.add({
            'name':   'Düşme (İvme)',
            'value':  '${s.value!.toStringAsFixed(1)} g',
            'status': '⚠ Düşme',
            'pct':    '',
          });
        } else {
          normalSensors.add({
            'name':  'Düşme (İvme)',
            'value': 'Tespit Yok',
          });
        }
        continue;
      }

      final bool kritik = s.status == 'critical' || s.status == 'risk';
      if (kritik) {
        final double pct = s.max > s.min
            ? ((s.value! - s.min) / (s.max - s.min) * 100).clamp(0.0, 100.0)
            : 0;
        anormalSensors.add({
          'name':   s.label,
          'value':  '${s.value!.toStringAsFixed(1)} ${s.unit}',
          'status': s.status == 'critical' ? 'Kritik' : 'Riskli',
          'pct':    '%${pct.toStringAsFixed(0)}',
        });
      } else {
        normalSensors.add({
          'name':  s.label,
          'value': '${s.value!.toStringAsFixed(1)} ${s.unit}',
        });
      }
    }

    final Color durumColor  = isAnormal ? const Color(0xFFDC2626) : const Color(0xFF059669);
    final Color durumBg     = isAnormal ? const Color(0xFFFFF1F2) : const Color(0xFFF0FDF4);
    final Color durumBorder = isAnormal ? const Color(0xFFFCA5A5) : const Color(0xFF86EFAC);

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Color(0xFF1A3A6B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Yelek $index',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF1A3A6B))),
            Text(ip,
              style: const TextStyle(fontSize: 10, color: Colors.grey, fontFamily: 'monospace')),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: durumBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: durumBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _PulsingDot(color: durumColor),
                const SizedBox(width: 5),
                Text(
                  isAnormal ? 'Anormal' : 'Normal',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: durumColor),
                ),
              ],
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          // ── CİHAZ BİLGİSİ ──────────────────────────────
          _buildSection(
            title: 'CİHAZ BİLGİSİ',
            child: Column(children: [
              _infoRow('Adı',         'Yelek $index'),
              _infoRow('Cihaz',       'ESP32'),
              _infoRow('IP',          ip),
              _infoRow('Son Görülme', lastSeen != null
                  ? '${lastSeen.hour.toString().padLeft(2,'0')}:${lastSeen.minute.toString().padLeft(2,'0')}:${lastSeen.second.toString().padLeft(2,'0')}'
                  : '—'),
              _infoRow('Bağlantı',    connected ? '✅ Bağlı' : 'Bağlı Değil'),
            ]),
          ),
          const SizedBox(height: 12),

          // ── DURUM BANNER ───────────────────────────────
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: durumBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: durumBorder, width: 1.5),
            ),
            child: Row(
              children: [
                Container(
                  width: 42, height: 42,
                  decoration: BoxDecoration(color: durumColor, shape: BoxShape.circle),
                  child: Icon(
                    isAnormal ? Icons.warning_rounded : Icons.check_circle_rounded,
                    color: Colors.white, size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isAnormal ? 'Durum: Anormal' : 'Durum: Normal',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: durumColor),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isAnormal ? 'Kritik sensörler tespit edildi!' : 'Tüm sensörler normal aralıkta',
                      style: TextStyle(fontSize: 11, color: durumColor.withOpacity(0.7)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── ANORMAL OLAY SAYISI ─────────────────────────
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: anormalSensors.isNotEmpty ? const Color(0xFFFEF2F2) : const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: anormalSensors.isNotEmpty ? const Color(0xFFFECACA) : const Color(0xFFE5E7EB),
              ),
            ),
            child: Row(
              children: [
                Text(
                  '${anormalSensors.length}',
                  style: TextStyle(
                    fontSize: 40, fontWeight: FontWeight.w900, height: 1,
                    color: anormalSensors.isNotEmpty ? const Color(0xFFDC2626) : const Color(0xFFD1D5DB),
                  ),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Anormal Olay Sayısı',
                      style: TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w700,
                        color: anormalSensors.isNotEmpty ? const Color(0xFFB91C1C) : const Color(0xFF9CA3AF),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      anormalSensors.isNotEmpty ? 'Eşik değeri aşılan sensörler' : 'Herhangi bir anormallik yok',
                      style: TextStyle(
                        fontSize: 11,
                        color: anormalSensors.isNotEmpty ? const Color(0xFFF87171) : const Color(0xFFD1D5DB),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── ANORMAL SENSÖRLER ───────────────────────────
          if (anormalSensors.isNotEmpty) ...[
            _sectionLabel('ANORMAL SENSÖR BİLGİLERİ'),
            const SizedBox(height: 6),
            _buildSection(
              title: '',
              child: Column(
                children: anormalSensors.map((s) => _sensorRow(
                  name:  s['name'],
                  value: s['value'],
                  badge: s['status'],
                  pct:   s['pct'],
                  isRed: true,
                )).toList(),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // ── NORMAL SENSÖRLER ────────────────────────────
          if (normalSensors.isNotEmpty) ...[
            _sectionLabel('NORMAL SENSÖR BİLGİLERİ (${normalSensors.length})'),
            const SizedBox(height: 6),
            _buildSection(
              title: '',
              child: Column(
                children: normalSensors.map((s) => _sensorRow(
                  name:  s['name'],
                  value: s['value'],
                  badge: '✓',
                  pct:   '',
                  isRed: false,
                )).toList(),
              ),
            ),
          ],

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ── Yardımcı widget'lar ────────────────────────────────

  Widget _buildSection({required String title, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)],
      ),
      child: Column(
        children: [
          if (title.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: const BoxDecoration(
                color: Color(0xFFF9FAFB),
                borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
                border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
              ),
              child: Text(title,
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.grey, letterSpacing: 1.0),
              ),
            ),
          child,
        ],
      ),
    );
  }

  Widget _infoRow(String key, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(key,   style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF1F2937), fontFamily: 'monospace')),
        ],
      ),
    );
  }

  Widget _sensorRow({
    required String name,
    required String value,
    required String badge,
    required String pct,
    required bool isRed,
  }) {
    final Color color      = isRed ? const Color(0xFFDC2626) : const Color(0xFF059669);
    final Color dotColor   = isRed ? const Color(0xFFEF4444) : const Color(0xFF22C55E);
    final Color badgeBg    = isRed ? const Color(0xFFFEF2F2) : const Color(0xFFECFDF5);
    final Color badgeBorder = isRed ? const Color(0xFFFECACA) : const Color(0xFFA7F3D0);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF9FAFB))),
      ),
      child: Row(
        children: [
          Container(
            width: 7, height: 7,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: dotColor,
              boxShadow: [BoxShadow(color: dotColor.withOpacity(0.4), blurRadius: 4)],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(name,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF1F2937)),
            ),
          ),
          Text(value,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color, fontFamily: 'monospace'),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: badgeBorder),
            ),
            child: Text(badge,
              style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: color),
            ),
          ),
          if (pct.isNotEmpty) ...[
            const SizedBox(width: 4),
            Text(pct, style: const TextStyle(fontSize: 9, color: Colors.grey, fontFamily: 'monospace')),
          ],
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.grey, letterSpacing: 1.2),
    );
  }
}

// ── Yanıp sönen nokta animasyonu ──────────────────────────
class _PulsingDot extends StatefulWidget {
  final Color color;
  const _PulsingDot({required this.color});

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.3, end: 1.0).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: Container(
        width: 10, height: 10,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.color,
          boxShadow: [BoxShadow(color: widget.color.withOpacity(0.5), blurRadius: 6, spreadRadius: 1)],
        ),
      ),
    );
  }
}