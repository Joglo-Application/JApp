import '../../domain/entities/shift_kas_entry.dart';

/// Representasi satu shift kas dari BE (`/shift-kas/*`).
class ShiftKasModel {
  const ShiftKasModel({
    required this.shiftId,
    required this.kasAwal,
    required this.status,
    required this.waktuMulai,
    required this.totalMasuk,
    required this.totalKeluar,
    required this.totalKas,
    required this.entries,
    this.kasAkhir,
    this.waktuSelesai,
  });

  final int shiftId;
  final int kasAwal;
  final String status; // 'open' | 'closed'
  final DateTime waktuMulai;
  final DateTime? waktuSelesai;
  final int? kasAkhir;
  final int totalMasuk;
  final int totalKeluar;
  final int totalKas;
  final List<ShiftKasEntry> entries;

  bool get isOpen => status == 'open';

  factory ShiftKasModel.fromJson(Map<String, dynamic> json) {
    final rawEntries = json['entries'] as List<dynamic>? ?? const [];
    return ShiftKasModel(
      shiftId: (json['shiftId'] as num).toInt(),
      kasAwal: (json['kasAwal'] as num).toInt(),
      status: json['status'] as String,
      waktuMulai: DateTime.parse(json['waktuMulai'] as String).toLocal(),
      waktuSelesai: json['waktuSelesai'] == null
          ? null
          : DateTime.parse(json['waktuSelesai'] as String).toLocal(),
      kasAkhir: (json['kasAkhir'] as num?)?.toInt(),
      totalMasuk: (json['totalMasuk'] as num).toInt(),
      totalKeluar: (json['totalKeluar'] as num).toInt(),
      totalKas: (json['totalKas'] as num).toInt(),
      entries: rawEntries.map((e) {
        final j = e as Map<String, dynamic>;
        return ShiftKasEntry(
          id: (j['entryId'] as num).toInt().toString(),
          jenis: j['jenis'] == 'penarikan'
              ? ShiftKasJenis.penarikan
              : ShiftKasJenis.setoran,
          namaTransaksi: j['namaTransaksi'] as String,
          jumlah: (j['jumlah'] as num).toDouble(),
          catatan: (j['catatan'] as String?) ?? '',
          lampiranUrl: j['lampiranUrl'] as String?,
          waktu: DateTime.parse(j['waktu'] as String).toLocal(),
        );
      }).toList(),
    );
  }
}
