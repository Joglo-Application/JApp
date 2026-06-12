class TransaksiItem {
  const TransaksiItem({
    required this.nama,
    required this.hargaSatuan,
    required this.qty,
    required this.total,
  });

  final String nama;
  final double hargaSatuan;
  final int qty;
  final double total;
}

class Transaksi {
  const Transaksi({
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
  final List<TransaksiItem> items;
  final double total;
  final bool isReturned;

  int get jumlahItem => items.length;

  List<String> get itemLabels =>
      items.map((i) => '${i.qty}x ${i.nama}').toList();

  Transaksi copyWith({bool? isReturned}) => Transaksi(
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
        items: items,
        total: total,
        isReturned: isReturned ?? this.isReturned,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Transaksi && other.kode == kode;

  @override
  int get hashCode => kode.hashCode;
}
