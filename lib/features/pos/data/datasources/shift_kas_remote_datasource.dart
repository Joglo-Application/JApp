import '../../../../core/network/api_client.dart';
import '../../domain/entities/shift_kas_entry.dart';
import '../models/shift_kas_model.dart';

abstract interface class ShiftKasRemoteDatasource {
  Future<ShiftKasModel?> fetchActive();
  Future<ShiftKasModel?> fetchByDate(DateTime date);
  Future<ShiftKasModel> startShift(int kasAwal);
  Future<ShiftKasModel> addEntry(
    int shiftId, {
    required ShiftKasJenis jenis,
    required String namaTransaksi,
    required int jumlah,
    String? catatan,
  });
  Future<ShiftKasModel> updateEntry(
    int entryId, {
    required String namaTransaksi,
    required int jumlah,
    String? catatan,
  });
  Future<ShiftKasModel> deleteEntry(int entryId);
  Future<ShiftKasModel> closeShift(int shiftId);
}

class ShiftKasRemoteDatasourceImpl implements ShiftKasRemoteDatasource {
  ShiftKasRemoteDatasourceImpl({ApiClient? client})
      : _client = client ?? ApiClient.instance;

  final ApiClient _client;

  ShiftKasModel _one(dynamic data) =>
      ShiftKasModel.fromJson(data as Map<String, dynamic>);

  @override
  Future<ShiftKasModel?> fetchActive() async {
    try {
      final res =
          await _client.dio.get<Map<String, dynamic>>('/shift-kas/aktif');
      final data = res.data?['data'];
      return data == null ? null : _one(data);
    } catch (e) {
      throw _client.toApiException(e);
    }
  }

  @override
  Future<ShiftKasModel?> fetchByDate(DateTime date) async {
    try {
      final res = await _client.dio.get<Map<String, dynamic>>(
        '/shift-kas',
        queryParameters: {'date': date.toIso8601String().substring(0, 10)},
      );
      final rows = res.data?['data'] as List<dynamic>? ?? const [];
      return rows.isEmpty ? null : _one(rows.first);
    } catch (e) {
      throw _client.toApiException(e);
    }
  }

  @override
  Future<ShiftKasModel> startShift(int kasAwal) async {
    try {
      final res = await _client.dio.post<Map<String, dynamic>>(
        '/shift-kas',
        data: {'kasAwal': kasAwal},
      );
      return _one(res.data!['data']);
    } catch (e) {
      throw _client.toApiException(e);
    }
  }

  @override
  Future<ShiftKasModel> addEntry(
    int shiftId, {
    required ShiftKasJenis jenis,
    required String namaTransaksi,
    required int jumlah,
    String? catatan,
  }) async {
    try {
      final res = await _client.dio.post<Map<String, dynamic>>(
        '/shift-kas/$shiftId/entry',
        data: {
          'jenis': jenis == ShiftKasJenis.penarikan ? 'penarikan' : 'setoran',
          'namaTransaksi': namaTransaksi,
          'jumlah': jumlah,
          'catatan': ?catatan,
        },
      );
      return _one(res.data!['data']);
    } catch (e) {
      throw _client.toApiException(e);
    }
  }

  @override
  Future<ShiftKasModel> updateEntry(
    int entryId, {
    required String namaTransaksi,
    required int jumlah,
    String? catatan,
  }) async {
    try {
      final res = await _client.dio.patch<Map<String, dynamic>>(
        '/shift-kas/entry/$entryId',
        data: {
          'namaTransaksi': namaTransaksi,
          'jumlah': jumlah,
          'catatan': ?catatan,
        },
      );
      return _one(res.data!['data']);
    } catch (e) {
      throw _client.toApiException(e);
    }
  }

  @override
  Future<ShiftKasModel> deleteEntry(int entryId) async {
    try {
      final res = await _client.dio
          .delete<Map<String, dynamic>>('/shift-kas/entry/$entryId');
      return _one(res.data!['data']);
    } catch (e) {
      throw _client.toApiException(e);
    }
  }

  @override
  Future<ShiftKasModel> closeShift(int shiftId) async {
    try {
      final res = await _client.dio
          .post<Map<String, dynamic>>('/shift-kas/$shiftId/tutup');
      return _one(res.data!['data']);
    } catch (e) {
      throw _client.toApiException(e);
    }
  }
}
