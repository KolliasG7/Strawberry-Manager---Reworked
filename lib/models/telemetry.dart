// lib/models/telemetry.dart

class CpuData {
  final double percent;
  final List<double> perCore;
  final int coreCount;
  final double freqMhz, freqMaxMhz;
  final double load1, load5, load15;

  const CpuData({
    required this.percent, required this.perCore, required this.coreCount,
    required this.freqMhz, required this.freqMaxMhz,
    required this.load1, required this.load5, required this.load15,
  });

  factory CpuData.fromJson(Map<String, dynamic> j) => CpuData(
    percent:    (j['percent']      as num).toDouble(),
    perCore:    (j['per_core']  as List).map((e) => (e as num).toDouble()).toList(),
    coreCount:  (j['core_count']   as num).toInt(),
    freqMhz:    (j['freq_mhz']     as num).toDouble(),
    freqMaxMhz: (j['freq_max_mhz'] as num? ?? 0).toDouble(),
    load1:      (j['load_1']       as num).toDouble(),
    load5:      (j['load_5']       as num).toDouble(),
    load15:     (j['load_15']      as num).toDouble(),
  );
}

class RamData {
  final double totalMb, usedMb, availableMb, cachedMb, buffersMb, percent;

  const RamData({
    required this.totalMb, required this.usedMb, required this.availableMb,
    required this.cachedMb, required this.buffersMb, required this.percent,
  });

  factory RamData.fromJson(Map<String, dynamic> j) => RamData(
    totalMb:    (j['total_mb']     as num).toDouble(),
    usedMb:     (j['used_mb']      as num).toDouble(),
    availableMb:(j['available_mb'] as num).toDouble(),
    cachedMb:   (j['cached_mb']    as num? ?? 0).toDouble(),
    buffersMb:  (j['buffers_mb']   as num? ?? 0).toDouble(),
    percent:    (j['percent']      as num).toDouble(),
  );
}

class SwapData {
  final double totalMb, usedMb, percent;
  const SwapData({required this.totalMb, required this.usedMb, required this.percent});
  factory SwapData.fromJson(Map<String, dynamic> j) => SwapData(
    totalMb: (j['total_mb'] as num).toDouble(),
    usedMb:  (j['used_mb']  as num).toDouble(),
    percent: (j['percent']  as num).toDouble(),
  );
}

class DiskData {
  final String mount, device, fstype;
  final double totalGb, usedGb, freeGb, percent, readBps, writeBps;

  const DiskData({
    required this.mount, required this.device, required this.fstype,
    required this.totalGb, required this.usedGb, required this.freeGb,
    required this.percent, required this.readBps, required this.writeBps,
  });

  factory DiskData.fromJson(Map<String, dynamic> j) => DiskData(
    mount:    j['mount']    as String? ?? '',
    device:   j['device']   as String? ?? '',
    fstype:   j['fstype']   as String? ?? '',
    totalGb:  (j['total_gb'] as num).toDouble(),
    usedGb:   (j['used_gb']  as num).toDouble(),
    freeGb:   (j['free_gb']  as num).toDouble(),
    percent:  (j['percent']  as num).toDouble(),
    readBps:  (j['read_bps']  as num? ?? 0).toDouble(),
    writeBps: (j['write_bps'] as num? ?? 0).toDouble(),
  );
}

class NetData {
  final String iface;
  final double bytesSentS, bytesRecvS;
  final int packetsSent, packetsRecv, errin, errout;

  const NetData({
    required this.iface, required this.bytesSentS, required this.bytesRecvS,
    required this.packetsSent, required this.packetsRecv,
    required this.errin, required this.errout,
  });

  factory NetData.fromJson(Map<String, dynamic> j) => NetData(
    iface:       j['iface']         as String? ?? '',
    bytesSentS:  (j['bytes_sent_s'] as num).toDouble(),
    bytesRecvS:  (j['bytes_recv_s'] as num).toDouble(),
    packetsSent: (j['packets_sent'] as num? ?? 0).toInt(),
    packetsRecv: (j['packets_recv'] as num? ?? 0).toInt(),
    errin:       (j['errin']        as num? ?? 0).toInt(),
    errout:      (j['errout']       as num? ?? 0).toInt(),
  );
}

class FanData {
  final int rpm, thresholdC;
  final double apuTempC;
  const FanData({required this.rpm, required this.thresholdC, required this.apuTempC});
  factory FanData.fromJson(Map<String, dynamic> j) => FanData(
    rpm:        (j['rpm']         as num).toInt(),
    thresholdC: (j['threshold_c'] as num).toInt(),
    apuTempC:   (j['apu_temp_c']  as num).toDouble(),
  );
}

class TunnelStatus {
  final String state;
  final String? url;
  const TunnelStatus({required this.state, this.url});
  factory TunnelStatus.fromJson(Map<String, dynamic> j) => TunnelStatus(
    state: j['state'] as String? ?? 'stopped',
    url:   j['url']   as String?,
  );
  bool get isRunning => state == 'running';
}

class TelemetryFrame {
  final double ts;
  final FanData? fan;
  final CpuData? cpu;
  final RamData? ram;
  final SwapData? swap;
  final List<DiskData> disk;
  final List<NetData> net;
  final int uptimeS;
  final TunnelStatus? tunnel;
  final String? error;

  const TelemetryFrame({
    required this.ts, this.fan, this.cpu, this.ram, this.swap,
    this.disk = const [], this.net = const [],
    this.uptimeS = 0, this.tunnel, this.error,
  });

  bool get isError => error != null;

  factory TelemetryFrame.fromJson(Map<String, dynamic> j) {
    if (j.containsKey('error')) {
      return TelemetryFrame(ts: (j['ts'] as num).toDouble(), error: j['error'] as String);
    }
    return TelemetryFrame(
      ts:      (j['ts']       as num).toDouble(),
      fan:     j['fan']  != null ? FanData.fromJson(j['fan'])   : null,
      cpu:     j['cpu']  != null ? CpuData.fromJson(j['cpu'])   : null,
      ram:     j['ram']  != null ? RamData.fromJson(j['ram'])   : null,
      swap:    j['swap'] != null ? SwapData.fromJson(j['swap']) : null,
      disk:    (j['disk'] as List? ?? []).map((e) => DiskData.fromJson(e)).toList(),
      net:     (j['net']  as List? ?? []).map((e) => NetData.fromJson(e)).toList(),
      uptimeS: (j['uptime_s'] as num? ?? 0).toInt(),
      tunnel:  j['tunnel'] != null ? TunnelStatus.fromJson(j['tunnel']) : null,
    );
  }

  String get uptimeFormatted {
    final d = uptimeS ~/ 86400;
    final h = (uptimeS % 86400) ~/ 3600;
    final m = (uptimeS % 3600)  ~/ 60;
    if (d > 0) return '${d}d ${h}h ${m}m';
    if (h > 0) return '${h}h ${m}m';
    return '${m}m';
  }

  NetData? get primaryNet {
    if (net.isEmpty) return null;
    return net.firstWhere(
      (n) => n.iface != 'lo' && (n.bytesSentS > 0 || n.bytesRecvS > 0),
      orElse: () => net.firstWhere((n) => n.iface != 'lo', orElse: () => net.first),
    );
  }
}
