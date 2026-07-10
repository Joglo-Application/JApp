enum ShiftKasJenis { setoran, penarikan }

class ShiftKasEntry {
  const ShiftKasEntry({
    required this.id,
    required this.jenis,
    required this.namaTransaksi,
    required this.jumlah,
    required this.waktu,
    this.catatan = '',
  });

  final String id;
  final ShiftKasJenis jenis;
  final String namaTransaksi;
  final String catatan;
  final double jumlah;
  final DateTime waktu;
}
