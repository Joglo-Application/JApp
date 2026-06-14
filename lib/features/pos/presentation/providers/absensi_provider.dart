import 'package:flutter/material.dart';

enum AbsensiStatus { belumHadir, sudahHadir, sudahPulang }

class AbsensiRecord {
  const AbsensiRecord({required this.waktu, required this.type});
  final DateTime waktu;
  final AbsensiStatus type;
}

class AbsensiProvider extends ChangeNotifier {
  AbsensiStatus _status = AbsensiStatus.belumHadir;
  DateTime? _waktuHadir;
  DateTime? _waktuPulang;
  final List<AbsensiRecord> _history = [];

  AbsensiStatus get status => _status;
  DateTime? get waktuHadir => _waktuHadir;
  DateTime? get waktuPulang => _waktuPulang;
  List<AbsensiRecord> get history => List.unmodifiable(_history);

  void hadir() {
    _status = AbsensiStatus.sudahHadir;
    _waktuHadir = DateTime.now();
    _history.add(AbsensiRecord(waktu: _waktuHadir!, type: AbsensiStatus.sudahHadir));
    notifyListeners();
  }

  void pulang() {
    _status = AbsensiStatus.sudahPulang;
    _waktuPulang = DateTime.now();
    _history.add(AbsensiRecord(waktu: _waktuPulang!, type: AbsensiStatus.sudahPulang));
    notifyListeners();
  }
}
