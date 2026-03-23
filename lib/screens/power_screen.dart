// lib/screens/power_screen.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme.dart';
import '../widgets/power_controls.dart';

class PowerScreen extends StatelessWidget {
  const PowerScreen({super.key, required this.api});
  final ApiService api;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Bk.oled,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('POWER'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
        child: Column(children: [
          PowerControlsCard(api: api),
          const SizedBox(height: 16),
          // Info card
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const StatLabel('NOTES'),
                const SizedBox(height: 10),
                _InfoRow(Icons.power_off_outlined,
                  'Shutdown',
                  'systemctl poweroff — full power off'),
                _InfoRow(Icons.refresh_outlined,
                  'Reboot',
                  'systemctl reboot — full restart'),
                _InfoRow(Icons.bedtime_outlined,
                  'Sleep',
                  'systemctl suspend — suspend to RAM'),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.icon, this.label, this.desc);
  final IconData icon; final String label, desc;
  @override Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(children: [
      Icon(icon, color: Bk.textDim, size: 14),
      const SizedBox(width: 10),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(
          color: Bk.textPri, fontSize: 12, fontWeight: FontWeight.w700)),
        Text(desc, style: const TextStyle(
          color: Bk.textDim, fontSize: 10)),
      ]),
    ]),
  );
}
