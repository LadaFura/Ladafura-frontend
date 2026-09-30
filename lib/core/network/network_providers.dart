import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'api_client.dart';
import 'auth_interceptor.dart';

part 'network_providers.g.dart';

/// Fournisseur singleton de l'instance [ApiClient].
@Riverpod(keepAlive: true)
ApiClient apiClient(ApiClientRef ref) {
  return ApiClient.instance;
}

/// Fournisseur d'accès direct au client [Dio].
@Riverpod(keepAlive: true)
Dio dio(DioRef ref) {
  return ref.watch(apiClientProvider).dio;
}

/// Fournisseur de l'intercepteur d'authentification [AuthInterceptor].
@Riverpod(keepAlive: true)
AuthInterceptor authInterceptor(AuthInterceptorRef ref) {
  return ref.watch(apiClientProvider).authInterceptor;
}
