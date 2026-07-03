// Modelos de dados espelhando as respostas da API.

class Nfe {
  final int id;
  final int numero;
  final int serie;
  final String status;
  final String? chave;
  final String destNome;
  final double valorTotal;
  final String? motivo;
  final String? protocolo;

  Nfe({
    required this.id,
    required this.numero,
    required this.serie,
    required this.status,
    required this.destNome,
    required this.valorTotal,
    this.chave,
    this.motivo,
    this.protocolo,
  });

  factory Nfe.fromJson(Map<String, dynamic> json) {
    return Nfe(
      id: json['id'] as int,
      numero: json['numero'] as int,
      serie: json['serie'] as int,
      status: json['status'] as String,
      chave: json['chave'] as String?,
      destNome: json['dest_nome'] as String? ?? '',
      valorTotal: double.tryParse('${json['valor_total']}') ?? 0,
      motivo: json['motivo'] as String?,
      protocolo: json['protocolo'] as String?,
    );
  }
}

/// Item da NF-e no formulário de criação.
class NfeItemInput {
  String codigo;
  String descricao;
  String ncm;
  String cfop;
  String unidade;
  double quantidade;
  double valorUnitario;
  String icmsCsosn;

  NfeItemInput({
    this.codigo = '',
    this.descricao = '',
    this.ncm = '',
    this.cfop = '5102',
    this.unidade = 'UN',
    this.quantidade = 1,
    this.valorUnitario = 0,
    this.icmsCsosn = '102',
  });

  Map<String, dynamic> toJson() => {
        'codigo': codigo,
        'descricao': descricao,
        'ncm': ncm,
        'cfop': cfop,
        'unidade': unidade,
        'quantidade': quantidade,
        'valor_unitario': valorUnitario,
        'icms_csosn': icmsCsosn,
      };
}
