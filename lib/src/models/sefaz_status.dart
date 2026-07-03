class SefazStatus {
  final String cStat;
  final String motivo;
  final int ambiente;
  final String uf;
  final bool online;

  SefazStatus({
    required this.cStat,
    required this.motivo,
    required this.ambiente,
    required this.uf,
    required this.online,
  });

  factory SefazStatus.fromJson(Map<String, dynamic> json) {
    return SefazStatus(
      cStat: '${json['cStat'] ?? ''}',
      motivo: '${json['motivo'] ?? ''}',
      ambiente: json['ambiente'] as int? ?? 2,
      uf: '${json['uf'] ?? ''}',
      online: json['online'] as bool? ?? false,
    );
  }

  String get ambienteLabel => ambiente == 1 ? 'Produção' : 'Homologação';
}
