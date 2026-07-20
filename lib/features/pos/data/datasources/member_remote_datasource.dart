import '../../../../core/network/api_client.dart';
import '../models/member_model.dart';

abstract class MemberRemoteDatasource {
  Future<List<MemberModel>> fetchMembers({String? q});

  Future<MemberModel> createMember({
    required String nama,
    String? noTelp,
    String? email,
    String? gender,
    String? tanggalLahir,
    String? alamat,
  });

  Future<MemberModel> updateMember({
    required int memberId,
    required String nama,
    String? noTelp,
    String? email,
    String? gender,
    String? tanggalLahir,
    String? alamat,
  });

  Future<void> deleteMember(int memberId);

  /// Menambah/mengurangi poin member sekaligus mencatatnya di server.
  Future<MemberModel> adjustPoin({
    required int memberId,
    required String tipe,
    required int poin,
  });

  Future<List<MemberTransaksiModel>> fetchTransaksiMember(int memberId);
}

class MemberRemoteDatasourceImpl implements MemberRemoteDatasource {
  MemberRemoteDatasourceImpl({ApiClient? client})
      : _client = client ?? ApiClient.instance;

  final ApiClient _client;

  @override
  Future<List<MemberModel>> fetchMembers({String? q}) async {
    // GET /member?q= — daftar member (read; semua role login).
    try {
      final res = await _client.dio.get<Map<String, dynamic>>(
        '/member',
        queryParameters: {
          'limit': 100,
          if (q != null && q.isNotEmpty) 'q': q,
        },
      );
      final rows = res.data?['data'] as List<dynamic>? ?? const [];
      return rows
          .map((e) => MemberModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw _client.toApiException(e);
    }
  }

  /// Hanya kirim field yang terisi — server menolak string kosong pada
  /// noTelp/email karena divalidasi panjang minimum dan format.
  Map<String, dynamic> _body({
    required String nama,
    String? noTelp,
    String? email,
    String? gender,
    String? tanggalLahir,
    String? alamat,
  }) {
    return {
      'nama': nama,
      if (noTelp != null && noTelp.isNotEmpty) 'noTelp': noTelp,
      if (email != null && email.isNotEmpty) 'email': email,
      if (gender != null && gender.isNotEmpty) 'gender': gender,
      if (tanggalLahir != null && tanggalLahir.isNotEmpty)
        'tanggalLahir': tanggalLahir,
      if (alamat != null && alamat.isNotEmpty) 'alamat': alamat,
    };
  }

  @override
  Future<MemberModel> createMember({
    required String nama,
    String? noTelp,
    String? email,
    String? gender,
    String? tanggalLahir,
    String? alamat,
  }) async {
    try {
      final res = await _client.dio.post<Map<String, dynamic>>(
        '/member',
        data: _body(
          nama: nama,
          noTelp: noTelp,
          email: email,
          gender: gender,
          tanggalLahir: tanggalLahir,
          alamat: alamat,
        ),
      );
      return MemberModel.fromJson(res.data?['data'] as Map<String, dynamic>);
    } catch (e) {
      throw _client.toApiException(e);
    }
  }

  @override
  Future<MemberModel> updateMember({
    required int memberId,
    required String nama,
    String? noTelp,
    String? email,
    String? gender,
    String? tanggalLahir,
    String? alamat,
  }) async {
    try {
      final res = await _client.dio.patch<Map<String, dynamic>>(
        '/member/$memberId',
        data: _body(
          nama: nama,
          noTelp: noTelp,
          email: email,
          gender: gender,
          tanggalLahir: tanggalLahir,
          alamat: alamat,
        ),
      );
      return MemberModel.fromJson(res.data?['data'] as Map<String, dynamic>);
    } catch (e) {
      throw _client.toApiException(e);
    }
  }

  @override
  Future<void> deleteMember(int memberId) async {
    try {
      await _client.dio.delete<Map<String, dynamic>>('/member/$memberId');
    } catch (e) {
      throw _client.toApiException(e);
    }
  }

  @override
  Future<MemberModel> adjustPoin({
    required int memberId,
    required String tipe,
    required int poin,
  }) async {
    try {
      final res = await _client.dio.post<Map<String, dynamic>>(
        '/member/$memberId/poin',
        data: {'tipe': tipe, 'poin': poin},
      );
      return MemberModel.fromJson(res.data?['data'] as Map<String, dynamic>);
    } catch (e) {
      throw _client.toApiException(e);
    }
  }

  @override
  Future<List<MemberTransaksiModel>> fetchTransaksiMember(int memberId) async {
    try {
      final res = await _client.dio.get<Map<String, dynamic>>(
        '/member/$memberId/transaksi',
      );
      final rows = res.data?['data'] as List<dynamic>? ?? const [];
      return rows
          .map((e) => MemberTransaksiModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw _client.toApiException(e);
    }
  }
}
