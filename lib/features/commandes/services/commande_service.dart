import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/network_providers.dart';
import '../models/commande_model.dart';

final commandeServiceProvider = Provider<CommandeService>((ref) {
  final dio = ref.watch(dioProvider);
  return CommandeService(dio);
});

class CommandeService {
  final Dio _dio;

  CommandeService(this._dio);

  Future<List<CommandeModel>> fetchMesCommandes() async {
    final response = await _dio.get('/population/commandes/mes-commandes');
    if (response.statusCode == 200 && response.data != null) {
      final List items = response.data['content'] is List
          ? response.data['content']
          : (response.data is List ? response.data : []);
      return items.map((e) => CommandeModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }
}
