import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../models/supplier_item_model.dart';

abstract class SupplierRemoteDatasource {
  Future<List<SupplierItemModel>> fetchItems();
  Future<void> createItem({
    required String namaBahan,
    required String satuan,
    required num stok,
    required num stokMinimum,
    String? kategori,
    String? imageUrl,
  });

  /// Mengunggah gambar dan mengembalikan URL publiknya.
  Future<String> uploadFoto({
    required List<int> bytes,
    required String namaFile,
  });
  Future<void> updateItem(
    int bahanId, {
    String? namaBahan,
    String? satuan,
    num? stok,
    num? stokMinimum,
    String? kategori,
    String? imageUrl,
  });
  Future<void> tambahStok(int bahanId, num jumlah);
  Future<void> deleteItem(int bahanId);
}

class SupplierRemoteDatasourceImpl implements SupplierRemoteDatasource {
  SupplierRemoteDatasourceImpl({ApiClient? client})
      : _client = client ?? ApiClient.instance;

  final ApiClient _client;

  @override
  Future<List<SupplierItemModel>> fetchItems() async {
    // GET /stok-gudang — daftar bahan baku (bentuk: id, bahanId, nama, ...).
    try {
      final res = await _client.dio.get<Map<String, dynamic>>('/stok-gudang');
      final rows = res.data?['data'] as List<dynamic>? ?? const [];
      return rows
          .map((e) => SupplierItemModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw _client.toApiException(e);
    }
  }

  @override
  Future<void> createItem({
    required String namaBahan,
    required String satuan,
    required num stok,
    required num stokMinimum,
    String? kategori,
    String? imageUrl,
  }) async {
    // POST /bahan-baku — tambah bahan baku baru.
    try {
      await _client.dio.post<Map<String, dynamic>>('/bahan-baku', data: {
        'namaBahan': namaBahan,
        'satuan': satuan,
        'stok': stok,
        'stokMinimum': stokMinimum,
        if (kategori != null && kategori.isNotEmpty) 'kategori': kategori,
        if (imageUrl != null && imageUrl.isNotEmpty) 'imageUrl': imageUrl,
      });
    } catch (e) {
      throw _client.toApiException(e);
    }
  }

  @override
  Future<String> uploadFoto({
    required List<int> bytes,
    required String namaFile,
  }) async {
    // POST /upload (multipart). Dikirim sebagai bytes, bukan path, supaya
    // tetap bekerja di web — di sana XFile.path berupa blob URL.
    try {
      final ext = namaFile.split('.').last.toLowerCase();
      final subtype = switch (ext) {
        'png' => 'png',
        'webp' => 'webp',
        _ => 'jpeg',
      };
      final form = FormData.fromMap({
        'file': MultipartFile.fromBytes(
          bytes,
          filename: namaFile,
          // Server menolak berkas yang tipenya bukan gambar, jadi tipe konten
          // harus disetel eksplisit.
          contentType: DioMediaType('image', subtype),
        ),
      });
      final res = await _client.dio.post<Map<String, dynamic>>(
        '/upload',
        data: form,
      );
      final data = res.data?['data'] as Map<String, dynamic>? ?? const {};
      return (data['url'] ?? '').toString();
    } catch (e) {
      throw _client.toApiException(e);
    }
  }

  @override
  Future<void> updateItem(
    int bahanId, {
    String? namaBahan,
    String? satuan,
    num? stok,
    num? stokMinimum,
    String? kategori,
    String? imageUrl,
  }) async {
    // PATCH /bahan-baku/:id — ubah bahan baku.
    try {
      await _client.dio.patch<Map<String, dynamic>>('/bahan-baku/$bahanId', data: {
        'namaBahan': ?namaBahan,
        'satuan': ?satuan,
        'stok': ?stok,
        'stokMinimum': ?stokMinimum,
        'kategori': ?kategori,
        'imageUrl': ?imageUrl,
      });
    } catch (e) {
      throw _client.toApiException(e);
    }
  }

  @override
  Future<void> tambahStok(int bahanId, num jumlah) async {
    // PATCH /bahan-baku/:id/tambah-stok — tambah stok atomik.
    try {
      await _client.dio.patch<Map<String, dynamic>>(
        '/bahan-baku/$bahanId/tambah-stok',
        data: {'jumlah': jumlah},
      );
    } catch (e) {
      throw _client.toApiException(e);
    }
  }

  @override
  Future<void> deleteItem(int bahanId) async {
    // DELETE /bahan-baku/:id — hapus (admin only di BE).
    try {
      await _client.dio.delete<Map<String, dynamic>>('/bahan-baku/$bahanId');
    } catch (e) {
      throw _client.toApiException(e);
    }
  }
}
