import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/network_providers.dart';
import '../../pharmacopees/models/pharmacopee_model.dart';

final carteServiceProvider = Provider<CarteService>((ref) {
  final dio = ref.watch(dioProvider);
  return CarteService(dio);
});

class CarteService {
  final Dio _dio;

  CarteService(this._dio);

  Future<List<PharmacopeeModel>> fetchPharmacopeesGeo() async {
    final response = await _dio.get('/population/pharmacopees', queryParameters: {
      'page': 0,
      'size': 50,
    });

    if (response.statusCode == 200 && response.data != null) {
      final List items = response.data['content'] is List
          ? response.data['content']
          : (response.data is List ? response.data : []);
      return items.map((e) => PharmacopeeModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }
}
