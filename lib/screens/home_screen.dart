import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/servis.dart';
import '../service/auth_service.dart';
import 'detail_screen.dart';
import 'form_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;
  String _cari = '';
  late Future<List<Servis>> _future;

  @override
  void initState() {
    super.initState();
    _future = _muat();
  }

  Future<List<Servis>> _muat() async {
    final id = await AuthService.currentUserId();
    if (id == null) return [];
    return DatabaseHelper.instance.getServis(id);
  }

  void _refresh() => setState(() => _future = _muat());

  Future<void> _tambah() async {
    final hasil = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const FormScreen()),
    );
    if (hasil == true) _refresh();
  }

  Future<void> _buka(Servis s) async {
    final hasil = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => DetailScreen(servis: s)),
    );
    if (hasil == true) _refresh();
  }

  Widget _daftar() {
    return FutureBuilder<List<Servis>>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final semua = snap.data ?? [];
        final data = semua
            .where((s) => s.judul.toLowerCase().contains(_cari.toLowerCase()))
            .toList();
        final total = data.fold<int>(0, (a, s) => a + s.biaya);

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Cari servis...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (v) => setState(() => _cari = v),
              ),
            ),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              child: ListTile(
                leading: const Icon(Icons.summarize),
                title: Text('${data.length} servis'),
                subtitle: Text('Total biaya: Rp $total'),
              ),
            ),
            Expanded(
              child: data.isEmpty
                  ? const Center(child: Text('Belum ada data servis'))
                  : ListView.builder(
                      itemCount: data.length,
                      itemBuilder: (_, i) {
                        final s = data[i];
                        return ListTile(
                          leading: const CircleAvatar(
                              child: Icon(Icons.build)),
                          title: Text(s.judul),
                          subtitle: Text('${s.tanggal} • Rp ${s.biaya}'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _buka(s),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_tab == 0 ? 'Riwayat Servis' : 'Profil')),
      body: IndexedStack(
        index: _tab,
        children: [_daftar(), const ProfileScreen()],
      ),
      floatingActionButton: _tab == 0
          ? FloatingActionButton(
              onPressed: _tambah, child: const Icon(Icons.add))
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.list), label: 'Servis'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }