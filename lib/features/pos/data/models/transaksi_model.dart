import '../../domain/entities/transaksi.dart';

class TransaksiItemModel {
  const TransaksiItemModel({
    required this.nama,
    required this.hargaSatuan,
    required this.qty,
    required this.total,
  });

  final String nama;
  final double hargaSatuan;
  final int qty;
  final double total;

  factory TransaksiItemModel.fromJson(Map<String, dynamic> json) {
    return TransaksiItemModel(
      nama: (json['nama'] ?? '').toString(),
      hargaSatuan: (json['hargaSatuan'] as num?)?.toDouble() ?? 0,
      qty: (json['qty'] as num?)?.toInt() ?? 0,
      total: (json['total'] as num?)?.toDouble() ?? 0,
    );
  }

  TransaksiItem toEntity() => TransaksiItem(
        nama: nama,
        hargaSatuan: hargaSatuan,
        qty: qty,
        total: total,
      );
}

class TransaksiModel {
  const TransaksiModel({
    required this.kode,
    required this.waktu,
    required this.namaStaff,
    required this.namaKontak,
    required this.tipePembayaran,
    required this.nominalPembayaran,
    required this.subtotal,
    required this.biayaLayananPct,
    required this.biayaLayanan,
    required this.pajakTokoPct,
    required this.pajakToko,
    required this.items,
    required this.total,
    this.isReturned = false,
  });

  final String kode;
  final DateTime waktu;
  final String namaStaff;
  final String namaKontak;
  final String tipePembayaran;
  final double nominalPembayaran;
  final double subtotal;
  final double biayaLayananPct;
  final double biayaLayanan;
  final double pajakTokoPct;
  final double pajakToko;
  final List<TransaksiItemModel> items;
  final double total;
  final bool isReturned;

  factory TransaksiModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    return TransaksiModel(
      kode: (json['kodeTransaksi'] ?? '').toString(),
      waktu: DateTime.tryParse(json['waktu'].toString()) ?? DateTime.now(),
      namaStaff: (json['namaStaff'] ?? '').toString(),
      namaKontak: (json['namaKontak'] ?? '').toString(),
      tipePembayaran: (json['tipePembayaran'] ?? '').toString(),
      nominalPembayaran: (json['nominalPembayaran'] as num?)?.toDouble() ?? 0,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0,
      biayaLayananPct: (json['biayaLayananPct'] as num?)?.toDouble() ?? 0,
      biayaLayanan: (json['biayaLayanan'] as num?)?.toDouble() ?? 0,
      pajakTokoPct: (json['pajakTokoPct'] as num?)?.toDouble() ?? 0,
      pajakToko: (json['pajakToko'] as num?)?.toDouble() ?? 0,
      items: rawItems
          .map((e) => TransaksiItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num?)?.toDouble() ?? 0,
      // Status retur kini datang dari server, bukan ditandai lokal.
      isReturned: json['isReturned'] == true,
    );
  }

  Transaksi toEntity() => Transaksi(
        kode: kode,
        waktu: waktu,
        namaStaff: namaStaff,
        namaKontak: namaKontak,
        tipePembayaran: tipePembayaran,
        nominalPembayaran: nominalPembayaran,
        subtotal: subtotal,
        biayaLayananPct: biayaLayananPct,
        biayaLayanan: biayaLayanan,
        pajakTokoPct: pajakTokoPct,
        pajakToko: pajakToko,
        items: items.map((i) => i.toEntity()).toList(),
        total: total,
        isReturned: isReturned,
      );
}
