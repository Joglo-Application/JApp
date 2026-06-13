class LogTransaksiEntry {
  const LogTransaksiEntry({
    required this.tipe,
    required this.kodeTransaksi,
    required this.namaKasir,
    required this.deskripsi,
    required this.waktu,
  });

  final String tipe;
  final String kodeTransaksi;
  final String namaKasir;
  final String deskripsi;
  final DateTime waktu;
}
