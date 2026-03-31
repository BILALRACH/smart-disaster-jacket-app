import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import 'sensors_screen.dart';
import 'alerts_screen.dart';
import 'control_screen.dart';
import 'yelek_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    SensorsScreen(),
    YelekScreen(),
    AlertsScreen(),
    ControlScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Image.asset('assets/logo.png', height: 32,
              errorBuilder: (c, e, s) => const Icon(Icons.shield, color: Color(0xFF1A3A6B), size: 32),
            ),
            const SizedBox(width: 10),
            const Text(
              'Akıllı Afet Ceketi',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A3A6B),
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: app.isConnected
                  ? const Color(0xFFF0FBF4)
                  : app.isConnecting
                      ? const Color(0xFFFFFBEB)
                      : const Color(0xFFF2F2F7),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: app.isConnected
                    ? const Color(0xFF1A7F4B).withOpacity(0.3)
                    : app.isConnecting
                        ? const Color(0xFFB45309).withOpacity(0.3)
                        : Colors.grey.withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: app.isConnected
                        ? const Color(0xFF1A7F4B)
                        : app.isConnecting
                            ? const Color(0xFFB45309)
                            : Colors.grey,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  app.isConnected ? 'Canlı' : app.isConnecting ? 'Bağlanıyor...' : 'Bağlı Değil',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: app.isConnected
                        ? const Color(0xFF1A7F4B)
                        : app.isConnecting
                            ? const Color(0xFFB45309)
                            : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      // ALARM BANNER
      body: Column(
        children: [
          if (app.globalAlarm)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              color: const Color(0xFFC0392B),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      '⚠️ SİSTEM ANORMAL — Alarm aktif!',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                    ),
                  ),

                ],
              ),
            ),
          Expanded(child: _screens[_currentIndex]),
        ],
      ),

      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFF1A3A6B).withOpacity(0.1),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.sensors_outlined),
            selectedIcon: Icon(Icons.sensors),
            label: 'Sensörler',
          ),
          NavigationDestination(
            icon: Icon(Icons.shield_outlined),
            selectedIcon: Icon(Icons.shield),
            label: 'Yelek',
          ),
          NavigationDestination(
            icon: Icon(Icons.warning_amber_outlined),
            selectedIcon: Icon(Icons.warning_amber_rounded),
            label: 'Alarmlar',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_remote_outlined),
            selectedIcon: Icon(Icons.settings_remote),
            label: 'Kontrol',
          ),
        ],
      ),
    );
  }
}