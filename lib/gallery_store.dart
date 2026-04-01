import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// تخزين قائمة روابط الصور محلياً (مثل «قاعدة بيانات» خفيفة).
/// لمشاريع أكبر مع جداول واستعلامات: استخدم [sqflite] أو Drift.
class GalleryStore {
  GalleryStore(this._prefs);

  final SharedPreferences _prefs;
  static const _key = 'gallery_urls_v1';

  static const _defaults = [
    'https://picsum.photos/id/10/800/600',
    'https://picsum.photos/id/29/800/600',
    'https://picsum.photos/id/40/800/600',
  ];

  static Future<GalleryStore> create() async {
    final p = await SharedPreferences.getInstance();
    final s = GalleryStore(p);
    if (s._readList().isEmpty) {
      await s._writeList(List.from(_defaults));
    }
    return s;
  }

  List<String> _readList() {
    final raw = _prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list.cast<String>();
    } catch (_) {
      return [];
    }
  }

  Future<void> _writeList(List<String> urls) async {
    await _prefs.setString(_key, jsonEncode(urls));
  }

  List<String> get urls => List.unmodifiable(_readList());

  Future<void> add(String url) async {
    final u = url.trim();
    if (u.isEmpty) return;
    final list = _readList();
    list.add(u);
    await _writeList(list);
  }

  Future<void> removeAt(int index) async {
    final list = _readList();
    if (index < 0 || index >= list.length) return;
    list.removeAt(index);
    await _writeList(list);
  }
}
