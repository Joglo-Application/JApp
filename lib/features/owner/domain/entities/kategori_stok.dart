class KategoriStok {
  KategoriStok({
    required this.id,
    required this.nama,
    this.fotoPath,
    this.produkCount = 0,
  });

  final String id;
  String nama;
  String? fotoPath;
  int produkCount;
}
