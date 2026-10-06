import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/network_providers.dart';

final panierServiceProvider = Provider<PanierService>((ref) {
  final dio = ref.watch(dioProvider);
  return PanierService(dio);
});

class PanierService {
  final Dio _dio;

  PanierService(this._dio);

  Future<void> validerCommande({
    required List<Map<String, dynamic>> items,
    required String adresseLivraison,
  }) async {
    await _dio.post('/population/commandes', data: {
      'items': items,
      'adresseLivraison': adresseLivraison,
    });
  }
}
