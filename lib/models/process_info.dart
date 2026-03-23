// lib/models/process_info.dart

class ProcessInfo {
  final int pid, threads;
  final String name, user, status, cmdline;
  final double cpuPct, memRssMb, memPct;

  const ProcessInfo({
    required this.pid, required this.threads,
    required this.name, required this.user,
    required this.status, required this.cmdline,
    required this.cpuPct, required this.memRssMb, required this.memPct,
  });

  factory ProcessInfo.fromJson(Map<String, dynamic> j) => ProcessInfo(
    pid:      (j['pid']         as num).toInt(),
    threads:  (j['threads']     as num? ?? 1).toInt(),
    name:     j['name']         as String? ?? '',
    user:     j['user']         as String? ?? '',
    status:   j['status']       as String? ?? '',
    cmdline:  j['cmdline']      as String? ?? '',
    cpuPct:   (j['cpu_pct']     as num).toDouble(),
    memRssMb: (j['mem_rss_mb']  as num).toDouble(),
    memPct:   (j['mem_pct']     as num).toDouble(),
  );
}
