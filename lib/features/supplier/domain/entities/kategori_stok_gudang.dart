class KategoriStokGudang {
  KategoriStokGudang({
    required this.id,
    required this.nama,
    this.produkCount = 0,
  });

  final String id;
  String nama;

  /// Jumlah bahan baku pada kategori ini (dihitung server).
  final int produkCount;
}
