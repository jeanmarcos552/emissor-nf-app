class Empresa {
  final int id;
  final String cnpj;
  final String razaoSocial;
  final String? nomeFantasia;
  final String? uf;
  final int ambiente;
  final bool certificadoOk;
  final String? certTitular;
  final String? certValidTo;

  Empresa({
    required this.id,
    required this.cnpj,
    required this.razaoSocial,
    required this.ambiente,
    required this.certificadoOk,
    this.nomeFantasia,
    this.uf,
    this.certTitular,
    this.certValidTo,
  });

  factory Empresa.fromJson(Map<String, dynamic> json) {
    return Empresa(
      id: json['id'] as int,
      cnpj: '${json['cnpj']}',
      razaoSocial: '${json['razao_social'] ?? ''}',
      nomeFantasia: json['nome_fantasia'] as String?,
      uf: json['uf'] as String?,
      ambiente: json['ambiente'] as int? ?? 2,
      certificadoOk: json['certificado_ok'] as bool? ?? false,
      certTitular: json['cert_titular'] as String?,
      certValidTo: json['cert_valid_to'] as String?,
    );
  }

  String get ambienteLabel => ambiente == 1 ? 'Produção' : 'Homologação';
}

/// Dados retornados pela busca de CNPJ (pré-preenchimento).
class CnpjInfo {
  final String cnpj;
  final String? razaoSocial;
  final String? uf;
  final String? municipio;

  CnpjInfo({required this.cnpj, this.razaoSocial, this.uf, this.municipio});

  factory CnpjInfo.fromJson(Map<String, dynamic> j) => CnpjInfo(
        cnpj: '${j['cnpj']}',
        razaoSocial: j['razao_social'] as String?,
        uf: j['uf'] as String?,
        municipio: j['municipio'] as String?,
      );
}
