import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../api/nfe_api.dart';
import '../models/empresa.dart';

class CertificadoScreen extends StatefulWidget {
  final NfeApi api;
  final Empresa empresa;
  const CertificadoScreen({super.key, required this.api, required this.empresa});

  @override
  State<CertificadoScreen> createState() => _CertificadoScreenState();
}

class _CertificadoScreenState extends State<CertificadoScreen> {
  final _senha = TextEditingController();
  List<int>? _bytes;
  String? _fileName;
  bool _loading = false;

  Future<void> _escolher() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pfx', 'p12'],
      withData: true, // necessário no web (path é nulo lá)
    );
    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _bytes = result.files.single.bytes;
        _fileName = result.files.single.name;
      });
    }
  }

  Future<void> _enviar() async {
    if (_bytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecione o arquivo .pfx')));
      return;
    }
    setState(() => _loading = true);
    try {
      await widget.api.uploadCertificado(widget.empresa.id, _bytes!, _fileName ?? 'certificado.pfx', _senha.text);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Certificado cadastrado!'), backgroundColor: Colors.green),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Certificado · ${widget.empresa.razaoSocial}')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Envie o certificado digital A1 (.pfx / e-CNPJ) desta empresa.'),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _escolher,
            icon: const Icon(Icons.attach_file),
            label: Text(_fileName ?? 'Selecionar arquivo .pfx'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _senha,
            decoration: const InputDecoration(labelText: 'Senha do certificado'),
            obscureText: true,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _loading ? null : _enviar,
            icon: _loading
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.upload),
            label: const Text('Enviar certificado'),
          ),
        ],
      ),
    );
  }
}
