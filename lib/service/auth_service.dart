import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/database_helper.dart';

class AuthService {
  static String _hash(String p) => sha256.convert(utf8.encode(p)).toString();

  static Future<bool> register(String nama, String email, String pass) async {
    final db = await DatabaseHelper.instance.db;
    try {
      await db.insert('users',
          {'nama': nama, 'email': email, 'password': _hash(pass)});
      return true;
    } catch (_) {
      return false; // email sudah terdaftar
    }
  }

  static Future<bool> login(String email, String pass) async {
    final db = await DatabaseHelper.instance.db;
    final res = await db.query('users',
        where: 'email = ? AND password = ?',
        whereArgs: [email, _hash(pass)]);
    if (res.isEmpty) return false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_id', res.first['id'] as int);
    await prefs.setString('nama', res.first['nama'] as String);
    return true;
  }

  static Future<int?> currentUserId() async =>
      (await SharedPreferences.getInstance()).getInt('user_id');

  static Future<String?> currentNama() async =>
      (await SharedPreferences.getInstance()).getString('nama');

  static Future<void> logout() async =>
      (await SharedPreferences.getInstance()).clear();
}