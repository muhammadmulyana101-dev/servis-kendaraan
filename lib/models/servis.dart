class Servis {
  final int? id;
  final int userId;
  final String judul;
  final String tanggal;
  final int biaya;
  final String? catatan;

  Servis({
    this.id,
    required this.userId,
    required this.judul,
    required this.tanggal,
    required this.biaya,
    this.catatan,
  });

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'user_id': userId,
        'judul': judul,
        'tanggal': tanggal,
        'biaya': biaya,
        'catatan': catatan,
      };

  factory Servis.fromMap(Map<String, dynamic> m) => Servis(
        id: m['id'] as int?,
        userId: m['user_id'] as int,
        judul: m['judul'] as String,
        tanggal: m['tanggal'] as String,
        biaya: m['biaya'] as int,
        catatan: m['catatan'] as String?,
      );
}