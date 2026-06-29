/// Pesanan yang sudah ada (pending) yang dimuat kembali ke POS untuk dibayar
/// lewat alur "Lihat Pesanan" pada meja. Dipetakan dari `GET /pesanan/:id`.
class LoadedPesananItem {
  const LoadedPesananItem({
    required this.detailId,
    this.menuId,
    this.namaCustom,
    required this.nama,
    required this.hargaSatuan,
    required this.jumlah,
    this.diskon = 0,
    this.catatan,
  });

  final int detailId;
  final int? menuId;
  final String? namaCustom;
  final String nama;
  final int hargaSatuan;
  final int jumlah;
  final int diskon;
  final String? catatan;

  factory LoadedPesananItem.fromJson(Map<String, dynamic> j) {
    return LoadedPesananItem(
      detailId: (j['detailId'] as num).toInt(),
      menuId: (j['menuId'] as num?)?.toInt(),
      namaCustom: j['namaCustom'] as String?,
      nama: (j['namaMenu'] ?? j['namaCustom'] ?? '').toString(),
      hargaSatuan: (j['hargaSatuan'] as num?)?.toInt() ?? 0,
      jumlah: (j['jumlah'] as num?)?.toInt() ?? 0,
      diskon: (j['diskon'] as num?)?.toInt() ?? 0,
      catatan: j['catatan'] as String?,
    );
  }
}

class LoadedPesanan {
  const LoadedPesanan({
    required this.pesananId,
    required this.total,
    this.mejaId,
    this.customerNama,
    this.orderType,
    this.createdAt,
    required this.items,
  });

  final int pesananId;
  final int total;
  final int? mejaId;
  final String? customerNama;
  final String? orderType;
  final DateTime? createdAt;
  final List<LoadedPesananItem> items;

  factory LoadedPesanan.fromJson(Map<String, dynamic> j) {
    final rawItems = j['items'] as List<dynamic>? ?? const [];
    return LoadedPesanan(
      pesananId: (j['pesananId'] as num).toInt(),
      total: (j['total'] as num?)?.toInt() ?? 0,
      mejaId: (j['mejaId'] as num?)?.toInt(),
      customerNama: j['customerNama'] as String?,
      orderType: j['orderType'] as String?,
      createdAt: DateTime.tryParse(j['createdAt']?.toString() ?? ''),
      items: rawItems
          .map((e) => LoadedPesananItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
