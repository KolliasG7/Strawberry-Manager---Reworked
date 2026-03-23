// lib/screens/settings_screen.dart — Braška settings
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/connection_provider.dart';
import '../theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _ctrl    = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isTunnel = false;

  @override
  void initState() {
    super.initState();
    final cp = context.read<ConnectionProvider>();
    _ctrl.text = cp.rawInput;
    _isTunnel  = cp.isTunnel;
  }

  void _onChanged(String v) {
    final t = v.startsWith('https://') || v.startsWith('http://') ||
              v.contains('.trycloudflare.com');
    if (t != _isTunnel) setState(() => _isTunnel = t);
  }

  Future<void> _connect() async {
    if (!_formKey.currentState!.validate()) return;
    final cp = context.read<ConnectionProvider>();
    await cp.connect(_ctrl.text.trim());
    if (!mounted) return;
    if (cp.connState != ConnState.error) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final cp = context.watch<ConnectionProvider>();

    // Live tunnel URL from latest telemetry frame
    final liveTunnelUrl = cp.frame?.tunnel?.url;
    final tunnelActive  = cp.frame?.tunnel?.isRunning ?? false;

    return Scaffold(
      backgroundColor: Bk.oled,
      appBar: AppBar(
        title: const Text('SETTINGS'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              // ── Mode badge ────────────────────────────
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Bk.surface1,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Bk.border),
                ),
                child: Row(children: [
                  Icon(_isTunnel ? Icons.cloud_outlined : Icons.lan_outlined,
                    color: Bk.white, size: 15),
                  const SizedBox(width: 10),
                  Text(
                    _isTunnel
                      ? 'CLOUDFLARE — encrypted, no port needed'
                      : 'LOCAL NETWORK — IP:port',
                    style: const TextStyle(
                      color: Bk.textSec, fontSize: 10, letterSpacing: 1.5),
                  ),
                ]),
              ),

              // ── Address card ──────────────────────────
              GlassCard(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const StatLabel('ADDRESS'),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _ctrl,
                      onChanged: _onChanged,
                      style: const TextStyle(
                        color: Bk.textPri, fontSize: 14,
                        fontWeight: FontWeight.w700),
                      decoration: InputDecoration(
                        hintText: _isTunnel
                          ? 'https://xxxx.trycloudflare.com'
                          : '192.168.1.116:8765',
                        hintStyle: const TextStyle(
                          color: Bk.textDim, fontSize: 13),
                        filled: true,
                        fillColor: Bk.oled,
                        prefixIcon: Icon(
                          _isTunnel
                            ? Icons.link_outlined
                            : Icons.lan_outlined,
                          color: Bk.textDim, size: 16),
                        suffixIcon: IconButton(
                          icon: const Icon(
                            Icons.clear, color: Bk.textDim, size: 14),
                          onPressed: () => setState(() {
                            _ctrl.clear(); _isTunnel = false;
                          })),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Bk.border)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Bk.border)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Bk.white, width: 1.5)),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Required';
                        if (!_isTunnel && !v.contains(':')) {
                          return 'Local address needs port';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // ── Connect button ────────────────────────
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: cp.connState == ConnState.connecting
                    ? null : _connect,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Bk.white.withOpacity(0.1),
                    foregroundColor: Bk.white,
                    side: BorderSide(
                      color: cp.connState == ConnState.connecting
                        ? Bk.border : Bk.white,
                      width: 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: Text(
                    cp.connState == ConnState.connecting
                      ? 'CONNECTING…' : 'CONNECT',
                    style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w900,
                      letterSpacing: 4)),
                ),
              ),

              if (cp.error != null) ...[
                const SizedBox(height: 12),
                GlassCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
                  child: Row(children: [
                    const Icon(Icons.error_outline,
                      color: Bk.white, size: 15),
                    const SizedBox(width: 10),
                    Expanded(child: Text(cp.error!,
                      style: const TextStyle(
                        color: Bk.textSec, fontSize: 12))),
                  ]),
                ),
              ],

              const SizedBox(height: 28),

              // ── Current tunnel status ─────────────────
              if (cp.isConnected) ...[
                const StatLabel('CLOUDFLARE TUNNEL'),
                const SizedBox(height: 12),

                // Show live URL if tunnel is running
                if (tunnelActive && liveTunnelUrl != null)
                  GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          const Icon(Icons.cloud_done_outlined,
                            color: Bk.white, size: 14),
                          const SizedBox(width: 8),
                          const Text('TUNNEL ACTIVE',
                            style: TextStyle(
                              color: Bk.textSec, fontSize: 10,
                              letterSpacing: 1.5, fontWeight: FontWeight.w700)),
                        ]),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Bk.oled,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Bk.border)),
                          child: Row(children: [
                            Expanded(child: Text(
                              liveTunnelUrl,
                              style: const TextStyle(
                                color: Bk.textPri, fontSize: 11),
                              overflow: TextOverflow.ellipsis)),
                            GestureDetector(
                              onTap: () {
                                Clipboard.setData(
                                  ClipboardData(text: liveTunnelUrl));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Copied'),
                                    duration: Duration(seconds: 1),
                                    behavior: SnackBarBehavior.floating));
                              },
                              child: const Padding(
                                padding: EdgeInsets.only(left: 10),
                                child: Icon(Icons.copy_outlined,
                                  size: 14, color: Bk.textDim))),
                          ]),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () {
                            _ctrl.text = liveTunnelUrl;
                            setState(() => _isTunnel = true);
                          },
                          child: const Text(
                            'TAP ADDRESS ABOVE TO SWITCH TO TUNNEL →',
                            style: TextStyle(
                              color: Bk.textDim, fontSize: 9,
                              letterSpacing: 1.5)),
                        ),
                      ],
                    ),
                  ),

                if (!tunnelActive) ...[
                  _TunnelCard(
                    api: cp.api!,
                    onStarted: (url) {
                      _ctrl.text = url;
                      setState(() => _isTunnel = true);
                      cp.connect(url);
                    },
                  ),
                ],

                const SizedBox(height: 12),

                // Always show "start new tunnel" option even if one is running
                if (tunnelActive)
                  _TunnelCard(
                    api: cp.api!,
                    label: 'START NEW TUNNEL',
                    onStarted: (url) {
                      _ctrl.text = url;
                      setState(() => _isTunnel = true);
                      cp.connect(url);
                    },
                  ),

                const SizedBox(height: 24),
              ],

              // ── Graph Settings ──────────────────────────
              const StatLabel('DASHBOARD PREFERENCES'),
              const SizedBox(height: 12),
              GlassCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(children: [
                  _PrefToggle(
                    label: 'Live CPU Graph',
                    val: cp.showCpuGraph,
                    onChanged: cp.toggleCpuGraph,
                  ),
                  const Divider(color: Bk.border, height: 1),
                  _PrefToggle(
                    label: 'Live RAM Graph',
                    val: cp.showRamGraph,
                    onChanged: cp.toggleRamGraph,
                  ),
                  const Divider(color: Bk.border, height: 1),
                  _PrefToggle(
                    label: 'Live Thermal / Fan Graphs',
                    val: cp.showThermalGraph,
                    onChanged: cp.toggleThermalGraph,
                  ),
                  const Divider(color: Bk.border, height: 1),
                  _PrefToggle(
                    label: 'Persistent Taskbar Notification',
                    val: cp.showNotifications,
                    onChanged: cp.toggleNotifications,
                  ),
                ]),
              ),
              const SizedBox(height: 24),

              // ── Disconnect ────────────────────────────
              if (cp.isConnected)
                TextButton(
                  onPressed: () {
                    cp.disconnect();
                    Navigator.pop(context);
                  },
                  child: const Text('DISCONNECT',
                    style: TextStyle(
                      color: Bk.textSec, fontSize: 11, letterSpacing: 2.5)),
                ),


              const SizedBox(height: 28),
              Center(
                child: Text(
                  'Braška  ·  by rmux🍓',
                  style: TextStyle(
                    color: Bk.textDim.withOpacity(0.5),
                    fontSize: 10, letterSpacing: 1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }
}

class _PrefToggle extends StatelessWidget {
  const _PrefToggle({required this.label, required this.val, required this.onChanged});
  final String label; final bool val; final void Function(bool) onChanged;
  @override Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label, style: const TextStyle(color: Bk.textPri, fontSize: 13, fontWeight: FontWeight.w700)),
      Switch(
        value: val,
        onChanged: onChanged,
        activeColor: Bk.cyan,
        activeTrackColor: Bk.cyan.withOpacity(0.3),
        inactiveTrackColor: Bk.surface2,
        inactiveThumbColor: Bk.textDim,
      ),
    ],
  );
}

class _TunnelCard extends StatefulWidget {
  const _TunnelCard({
    required this.api,
    required this.onStarted,
    this.label = 'START TUNNEL',
  });
  final dynamic api;
  final void Function(String) onStarted;
  final String label;
  @override State<_TunnelCard> createState() => _TunnelCardState();
}

class _TunnelCardState extends State<_TunnelCard> {
  bool    _loading = false;
  String? _url, _err;

  Future<void> _start() async {
    setState(() { _loading = true; _err = null; _url = null; });
    try {
      final res = await widget.api.startTunnel();
      final url = res['url'] as String;
      // Persist for next launch
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_tunnel_url', url);
      await Clipboard.setData(ClipboardData(text: url));
      if (!mounted) return;
      setState(() { _url = url; _loading = false; });
      await Future.delayed(const Duration(seconds: 5));
      widget.onStarted(url);
    } catch (e) {
      if (!mounted) return;
      setState(() { _err = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(children: [
            const Icon(Icons.cloud_queue_outlined,
              color: Bk.white, size: 15),
            const SizedBox(width: 8),
            const Text('Quick Tunnel via pycloudflared',
              style: TextStyle(color: Bk.textPri, fontSize: 13,
                fontWeight: FontWeight.w800)),
          ]),
          const SizedBox(height: 6),
          const Text(
            'Encrypted HTTPS tunnel. '
            'App reconnects automatically in 5s.',
            style: TextStyle(color: Bk.textSec, fontSize: 11, height: 1.5)),

          if (_url != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Bk.oled,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Bk.border)),
              child: Row(children: [
                Expanded(child: Text(_url!,
                  style: const TextStyle(color: Bk.textPri, fontSize: 11),
                  overflow: TextOverflow.ellipsis)),
                GestureDetector(
                  onTap: () =>
                    Clipboard.setData(ClipboardData(text: _url!)),
                  child: const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Icon(Icons.copy_outlined,
                      size: 14, color: Bk.textDim))),
              ]),
            ),
            const SizedBox(height: 6),
            const Text('↳ Copied · reconnecting in 5s…',
              style: TextStyle(color: Bk.textSec, fontSize: 11)),
          ],

          if (_err != null) ...[
            const SizedBox(height: 8),
            Text('✗ $_err',
              style: const TextStyle(color: Bk.textSec, fontSize: 11)),
          ],

          const SizedBox(height: 12),

          SizedBox(
            height: 44,
            child: ElevatedButton.icon(
              onPressed: _loading ? null : _start,
              style: ElevatedButton.styleFrom(
                backgroundColor: Bk.white.withOpacity(0.08),
                foregroundColor: Bk.white,
                side: const BorderSide(color: Bk.border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              icon: _loading
                ? const SizedBox(
                    width: 13, height: 13,
                    child: CircularProgressIndicator(
                      strokeWidth: 2, color: Bk.white))
                : const Icon(Icons.rocket_launch_outlined, size: 14),
              label: Text(
                _loading ? 'STARTING…' : widget.label,
                style: const TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w900,
                  letterSpacing: 2)),
            ),
          ),
        ],
      ),
    );
  }
}
