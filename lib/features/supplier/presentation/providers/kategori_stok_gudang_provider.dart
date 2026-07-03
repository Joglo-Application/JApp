import 'package:flutter/foundation.dart';

import '../../domain/entities/kategori_stok_gudang.dart';

class KategoriStokGudangProvider extends ChangeNotifier {
  final List<KategoriStokGudang> _list = [
    KategoriStokGudang(id: '1', nama: 'Frozen Food'),
    KategoriStokGudang(id: '2', nama: 'Saos'),
    KategoriStokGudang(id: '3', nama: 'Cabe'),
  ];
  int _counter = 3;

  List<KategoriStokGudang> get list => List.unmodifiable(_list);

  String generateId() {
    _counter++;
    return '$_counter';
  }

  void addKategori(KategoriStokGudang kategori) {
    _list.add(kategori);
    notifyListeners();
  }

  void updateKategori(KategoriStokGudang updated) {
    final i = _list.indexWhere((e) => e.id == updated.id);
    if (i != -1) {
      _list[i] = updated;
      notifyListeners();
    }
  }

  void removeKategori(String id) {
    _list.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  void reorderKategori(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex--;
    final item = _list.removeAt(oldIndex);
    _list.insert(newIndex, item);
    notifyListeners();
  }
}
