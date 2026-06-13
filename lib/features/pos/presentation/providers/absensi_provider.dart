import 'package:flutter/material.dart';

enum AbsensiStatus { belumHadir, sudahHadir, sudahPulang }

class AbsensiProvider extends ChangeNotifier {
  AbsensiStatus _status = AbsensiStatus.belumHadir;
  DateTime? _waktuHadir;
  DateTime? _waktuPulang;

  AbsensiStatus get status => _status;
  DateTime? get waktuHadir => _waktuHadir;
  DateTime? get waktuPulang => _waktuPulang;

  void hadir() {
    _status = AbsensiStatus.sudahHadir;
    _waktuHadir = DateTime.now();
    notifyListeners();
  }

  void pulang() {
    _status = AbsensiStatus.sudahPulang;
    _waktuPulang = DateTime.now();
    notifyListeners();
  }
}
