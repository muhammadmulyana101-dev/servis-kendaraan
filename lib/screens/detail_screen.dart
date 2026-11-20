import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/servis.dart';
import 'form_screen.dart';

class DetailScreen extends StatelessWidget {
  final Servis servis;
  const DetailScreen({super.key, required this.servis});

  Future<void> _hapus(BuildContext context) async {
    final ya = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus data?'),
        content: Text('"${servis.judul}" akan dihapus permanen.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Hapus')),
        ],
      ),
    );
    if (ya == true) {
      await DatabaseHelper.instance.deleteServis(servis.id!);
      if (context.mounted) Navigator.pop(context, true);
    }
  }

  Future<void> _edit(BuildContext context) async {
    final hasil = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => FormScreen(servis: servis)),
    );
    if (hasil == true && context.mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Servis')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(servis.judul,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListTile(
                leading: const Icon(Icons.calendar_today),
                title: Text(servis.tanggal)),
            ListTile(
                leading: const Icon(Icons.payments),
                title: Text('Rp ${servis.biaya}')),
            ListTile(
                leading: const Icon(Icons.notes),
                title: Text(servis.catatan ?? '-')),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _edit(context),
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _hapus(context),
                    icon: const Icon(Icons.delete),
                    label: const Text('Hapus'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}