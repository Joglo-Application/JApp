class AbsensiRecord {
  const AbsensiRecord({
    required this.nama,
    required this.tanggal,
    required this.jamMasuk,
    required this.jamKeluar,
  });

  final String nama;
  final DateTime tanggal;
  final String jamMasuk;
  final String jamKeluar;
}
