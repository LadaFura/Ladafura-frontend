import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/network_providers.dart';
import '../models/profil_model.dart';

final profilServiceProvider = Provider<ProfilService>((ref) {
  final dio = ref.watch(dioProvider);
  return ProfilService(dio);
});

class ProfilService {
  final Dio _dio;

  ProfilService(this._dio);

  Future<ProfilModel?> fetchMonProfil() async {
    final response = await _dio.get('/population/auth/me');
    if (response.statusCode == 200 && response.data != null) {
      return ProfilModel.fromJson(response.data as Map<String, dynamic>);
    }
    return null;
  }
}
