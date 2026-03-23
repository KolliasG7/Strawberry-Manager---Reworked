// lib/screens/connect_screen.dart — Braška landing
import 'dart:io';
import 'dart:math' as math;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/connection_provider.dart';
import '../theme.dart';

class ConnectScreen extends StatefulWidget {
  const ConnectScreen({super.key});
  @override State<ConnectScreen> createState() => _ConnectScreenState();
}

class _ConnectScreenState extends State<ConnectScreen> {
  final _ctrl    = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isTunnel = false;

  // Last known tunnel URL loaded from prefs
  String? _lastTunnelUrl;

  @override
  void initState() {
    super.initState();
    final cp = context.read<ConnectionProvider>();
    _ctrl.text = cp.rawInput;
    _isTunnel  = cp.isTunnel;
    _loadLastTunnel();
  }

  Future<void> _loadLastTunnel() async {
    final prefs = await SharedPreferences.getInstance();
    final url = prefs.getString('last_tunnel_url');
    if (url != null && mounted) setState(() => _lastTunnelUrl = url);
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
    if (cp.connState == ConnState.needsAuth) _showPasswordDialog();
  }

  Future<void> _showPasswordDialog() async {
    final cp   = context.read<ConnectionProvider>();
    final ctrl = TextEditingController();
    bool  obscure = true;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          backgroundColor: Bk.surface1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Bk.border)),
          title: const Text('PASSWORD',
            style: TextStyle(color: Bk.textPri, fontSize: 15,
              fontWeight: FontWeight.w900, letterSpacing: 2)),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('Enter the Braška backend password.',
              style: TextStyle(color: Bk.textSec, fontSize: 12, height: 1.5)),
            const SizedBox(height: 16),
            TextField(
              controller: ctrl,
              obscureText: obscure,
              autofocus: true,
              style: const TextStyle(color: Bk.textPri, fontSize: 14,
                fontFamily: 'monospace'),
              decoration: InputDecoration(
                hintText: 'password',
                hintStyle: const TextStyle(color: Bk.textDim),
                filled: true, fillColor: Bk.oled,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Bk.border)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Bk.border)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Bk.white, width: 1.5)),
                suffixIcon: IconButton(
                  icon: Icon(obscure
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                    color: Bk.textDim, size: 16),
                  onPressed: () => setS(() => obscure = !obscure)),
              ),
            ),
            if (cp.error != null && cp.connState == ConnState.needsAuth) ...[
              const SizedBox(height: 10),
              Text(cp.error!,
                style: const TextStyle(color: Bk.textSec, fontSize: 11)),
            ],
          ]),
          actions: [
            TextButton(
              onPressed: () {
                cp.disconnect();
                Navigator.pop(ctx);
              },
              child: const Text('CANCEL',
                style: TextStyle(color: Bk.textDim, fontSize: 11,
                  letterSpacing: 1.5))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Bk.white.withOpacity(0.1),
                foregroundColor: Bk.white,
                elevation: 0,
                side: const BorderSide(color: Bk.border),
              ),
              onPressed: () async {
                Navigator.pop(ctx);
                await cp.login(ctrl.text);
              },
              child: const Text('UNLOCK',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900,
                  letterSpacing: 2))),
          ],
        ),
      ),
    );

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) ctrl.dispose();
    });
  }

  void _useTunnelUrl(String url) {
    _ctrl.text = url;
    setState(() => _isTunnel = true);
  }

  @override
  Widget build(BuildContext context) {
    final cp         = context.watch<ConnectionProvider>();
    final connecting = cp.connState == ConnState.connecting;

    return Scaffold(
      backgroundColor: Bk.oled,
      resizeToAvoidBottomInset: false,
      body: Stack(children: [
        SafeArea(
          child: Form(
            key: _formKey,
            child: Column(children: [
              const Spacer(flex: 2),

              const _BraskaLogo(),
              const SizedBox(height: 28),

              const Text('BRAŠKA', style: TextStyle(
                color: Bk.textPri, fontSize: 28,
                fontWeight: FontWeight.w900, letterSpacing: 8)),
              const SizedBox(height: 6),
              const Text('PLAYSTATION 4 · LINUX', style: TextStyle(
                color: Bk.textDim, fontSize: 10, letterSpacing: 4)),

              const Spacer(flex: 2),

              // Input card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Icon(
                          _isTunnel
                            ? Icons.cloud_outlined
                            : Icons.wifi_outlined,
                          color: Bk.white, size: 14),
                        const SizedBox(width: 8),
                        Text(
                          _isTunnel ? 'CLOUDFLARE TUNNEL' : 'LOCAL NETWORK',
                          style: const TextStyle(
                            color: Bk.textSec,
                            fontSize: 9, letterSpacing: 2.5,
                            fontWeight: FontWeight.w900)),
                      ]),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _ctrl,
                        onChanged: _onChanged,
                        style: const TextStyle(
                          color: Bk.textPri, fontSize: 15,
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
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Bk.border)),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Bk.border)),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Bk.white, width: 1.5)),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Bk.border)),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 14),
                        ),
                        validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),

                      // Last tunnel URL hint
                      if (_lastTunnelUrl != null &&
                          _lastTunnelUrl != _ctrl.text) ...[
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: () => _useTunnelUrl(_lastTunnelUrl!),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Bk.surface2,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Bk.border),
                            ),
                            child: Row(children: [
                              const Icon(Icons.history_outlined,
                                color: Bk.textDim, size: 13),
                              const SizedBox(width: 8),
                              Expanded(child: Text(
                                _lastTunnelUrl!.replaceAll('https://', ''),
                                style: const TextStyle(
                                  color: Bk.textSec, fontSize: 11),
                                overflow: TextOverflow.ellipsis)),
                              const SizedBox(width: 6),
                              const Text('USE',
                                style: TextStyle(
                                  color: Bk.textSec, fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.5)),
                            ]),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Connect button — no spinner, just text
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: connecting ? null : _connect,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Bk.white.withOpacity(0.1),
                      foregroundColor: Bk.white,
                      side: BorderSide(
                        color: connecting ? Bk.border : Bk.white,
                        width: 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: Text(
                      connecting ? 'CONNECTING…' : 'CONNECT',
                      style: TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w900,
                        letterSpacing: 4,
                        color: connecting ? Bk.textDim : Bk.white)),
                  ),
                ),
              ),

              // Error
              if (cp.error != null) ...[
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: GlassCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                    child: Row(children: [
                      const Icon(Icons.error_outline,
                        color: Bk.white, size: 15),
                      const SizedBox(width: 10),
                      Expanded(child: Text(cp.error!,
                        style: const TextStyle(
                          color: Bk.textSec, fontSize: 12))),
                    ]),
                  ),
                ),
              ],

              const SizedBox(height: 16),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: _showPayloadInjector,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Bk.white,
                      side: const BorderSide(color: Bk.border, width: 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    ),
                    icon: const Icon(Icons.rocket_launch_outlined, size: 15, color: Bk.textSec),
                    label: const Text('INJECT LINUX PAYLOAD',
                      style: TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w900,
                        letterSpacing: 2.5, color: Bk.textSec)),
                  ),
                ),
              ),

              const Spacer(flex: 3),

              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Text(
                  'by rmux  ·  Braška 🍓',
                  style: TextStyle(
                    color: Bk.textDim.withOpacity(0.5),
                    fontSize: 10, letterSpacing: 1)),
              ),
            ]),
          ),
        ),
      ]),
    );
  }

  Future<void> _showPayloadInjector() async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: false,
    );
    if (res == null || res.files.single.path == null) return;

    final file = File(res.files.single.path!);

    String ip = '192.168.1.68';
    final currentInput = _ctrl.text.trim();
    if (currentInput.isNotEmpty && !currentInput.startsWith('http')) {
      ip = currentInput.split(':').first;
    }

    if (!mounted) return;
    final ipCtrl = TextEditingController(text: ip);
    final portCtrl = TextEditingController(text: '9023');

    await showDialog(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: Bk.surface1,
        title: const Text('INJECT PAYLOAD', style: TextStyle(color: Bk.white, fontSize: 14, letterSpacing: 2, fontWeight: FontWeight.w900)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('File: ${res.files.single.name}', style: const TextStyle(color: Bk.textSec, fontSize: 12)),
            const SizedBox(height: 16),
            TextField(
              controller: ipCtrl,
              style: const TextStyle(color: Bk.textPri, fontSize: 13),
              decoration: const InputDecoration(labelText: 'IP Address', labelStyle: TextStyle(color: Bk.textDim)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: portCtrl,
              style: const TextStyle(color: Bk.textPri, fontSize: 13),
              decoration: const InputDecoration(labelText: 'Port (usually 9020 or 9023)', labelStyle: TextStyle(color: Bk.textDim)),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('CANCEL', style: TextStyle(color: Bk.textDim, fontSize: 11)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Bk.white.withOpacity(0.1), foregroundColor: Bk.white, elevation: 0),
            onPressed: () {
              Navigator.pop(c);
              _injectPayload(ipCtrl.text.trim(), int.tryParse(portCtrl.text.trim()) ?? 9023, file);
            },
            child: const Text('SEND', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 2)),
          ),
        ],
      ),
    );

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        ipCtrl.dispose();
        portCtrl.dispose();
      }
    });
  }

  Future<void> _injectPayload(String ip, int port, File file) async {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Bk.surface2,
      content: Text('Connecting to $ip:$port...', style: const TextStyle(color: Bk.white, fontSize: 12))));
      
    try {
      final socket = await Socket.connect(ip, port, timeout: const Duration(seconds: 3));
      if (!mounted) return;
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Bk.surface2,
        content: Text('Sending ${file.path.split('/').last}...', style: const TextStyle(color: Bk.textSec, fontSize: 12))));
      
      await socket.addStream(file.openRead());
      await socket.flush();
      socket.destroy();
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('✓ Payload sent successfully!', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900)), 
        backgroundColor: Colors.green));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: $e', style: const TextStyle(color: Colors.white, fontSize: 12)), 
        backgroundColor: Colors.red.shade900));
    }
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }
}

// ── Logo ──────────────────────────────────────────────────────────────────

class _BraskaLogo extends StatelessWidget {
  const _BraskaLogo();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70, height: 70,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Bk.surface1,
        border: Border.all(color: Bk.border, width: 1.5),
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/logo.png',
          width: 70, height: 70,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
