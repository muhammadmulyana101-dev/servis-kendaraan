import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/servis.dart';
import '../service/auth_service.dart';

class FormScreen extends StatefulWidget {
  final Servis? servis;
  const FormScreen({super.key, this.servis});

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _judul;
  late final TextEditingController _tanggal;
  late final TextEditingController _biaya;
  late final TextEditingController _catatan;

  bool get _isEdit => widget.servis != null;

  @override
  void initState() {
    super.initState();
    final s = widget.servis;
    _judul = TextEditingController(text: s?.judul ?? '');
    _tanggal = TextEditingController(
        text: s?.tanggal ?? DateTime.now().toString().substring(0, 10));
    _biaya = TextEditingController(text: s?.biaya.toString() ?? '');
    _catatan = TextEditingController(text: s?.catatan ?? '');
  }

  @override
  void dispose() {
    _judul.dispose();
    _tanggal.dispose();
    _biaya.dispose();
    _catatan.dispose();
    super.dispose();
  }

  Future<void> _pilihTanggal() async {
    final d = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(_tanggal.text) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (d != null) {
      _tanggal.text = d.toString().substring(0, 10);
    }
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;
    final userId = await AuthService.currentUserId();
    if (userId == null) return;

    final data = Servis(
      id: widget.servis?.id,
      userId: userId,
      judul: _judul.text.trim(),
      tanggal: _tanggal.text,
      biaya: int.parse(_biaya.text),
      catatan: _catatan.text.trim().isEmpty ? null : _catatan.text.trim(),
    );

    if (_isEdit) {
      await DatabaseHelper.instance.updateServis(data);
    } else {
      await DatabaseHelper.instance.insertServis(data);
    }
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Edit Servis' : 'Tambah Servis')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _judul,
                decoration: const InputDecoration(
                    labelText: 'Jenis servis (mis. Ganti oli)',
                    border: OutlineInputBorder()),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Wajib diisi'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _tanggal,
                readOnly: true,
                onTap: _pilihTanggal,
                decoration: const InputDecoration(
                    labelText: 'Tanggal',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today)),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _biaya,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: 'Biaya (Rp)', border: OutlineInputBorder()),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Wajib diisi';
                  if (int.tryParse(v) == null) return 'Harus berupa angka';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _catatan,
                maxLines: 3,
                decoration: const InputDecoration(
                    labelText: 'Catatan (opsional)',
                    border: OutlineInputBorder()),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: _simpan,
                  child: Text(_isEdit ? 'Simpan Perubahan' : 'Simpan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}