import '../../../../core/network/api_client.dart';
import '../../domain/entities/order_item.dart';

/// Satu tarif toko (Pajak atau Biaya Layanan).
class TarifItem {
  const TarifItem({
    required this.tipe,
    required this.nilai,
    required this.aktif,
  });

  /// percent → [nilai] adalah angka persen (mis. 10); amount → nominal Rupiah.
  final DiscountType tipe;
  final double nilai;
  final bool aktif;
}

/// Tarif toko yang tersimpan di server (grup pengaturan `pajak`).
class TarifSetting {
  const TarifSetting({required this.pajak, required this.layanan});

  final TarifItem pajak;
  final TarifItem layanan;
}

/// Baca & ubah default Pajak / Biaya Layanan toko lewat API pengaturan.
abstract class TarifSettingDatasource {
  Future<TarifSetting> fetch();

  /// Ubah cepat dari POS — butuh PIN supervisor (server memverifikasinya).
  /// [target] = 'pajak' | 'layanan'.
  Future<TarifSetting> update({
    required String target,
    required DiscountType tipe,
    required double nilai,
    required String pin,
  });
}

class TarifSettingDatasourceImpl implements TarifSettingDatasource {
  TarifSettingDatasourceImpl({ApiClient? client})
      : _client = client ?? ApiClient.instance;

  final ApiClient _client;

  @override
  Future<TarifSetting> fetch() async {
    try {
      final res =
          await _client.dio.get<Map<String, dynamic>>('/pengaturan/pajak');
      return _parse(res.data?['data'] as Map<String, dynamic>? ?? const {});
    } catch (e) {
      throw _client.toApiException(e);
    }
  }

  @override
  Future<TarifSetting> update({
    required String target,
    required DiscountType tipe,
    required double nilai,
    required String pin,
  }) async {
    try {
      final res = await _client.dio.put<Map<String, dynamic>>(
        '/pengaturan/pajak/cepat',
        data: {
          'target': target,
          'tipe': tipe == DiscountType.amount ? 'amount' : 'percent',
          'nilai': nilai,
          'pin': pin,
        },
      );
      return _parse(res.data?['data'] as Map<String, dynamic>? ?? const {});
    } catch (e) {
      throw _client.toApiException(e);
    }
  }

  TarifSetting _parse(Map<String, dynamic> d) {
    TarifItem item(String tipeKey, String persenKey, String nominalKey, String aktifKey) {
      final tipe =
          (d[tipeKey] as String?) == 'amount' ? DiscountType.amount : DiscountType.percent;
      final nilai = tipe == DiscountType.amount
          ? (d[nominalKey] as num?)?.toDouble() ?? 0
          : (d[persenKey] as num?)?.toDouble() ?? 0;
      return TarifItem(tipe: tipe, nilai: nilai, aktif: d[aktifKey] as bool? ?? true);
    }

    return TarifSetting(
      pajak: item('pajakTipe', 'pajakPersen', 'pajakNominal', 'pajakAktif'),
      layanan: item(
        'biayaLayananTipe',
        'biayaLayananPersen',
        'biayaLayananNominal',
        'biayaLayananAktif',
      ),
    );
  }
}
