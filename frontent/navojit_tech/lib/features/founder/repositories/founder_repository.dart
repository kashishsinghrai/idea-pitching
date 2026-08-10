import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final founderRepositoryProvider = Provider((ref) => FounderRepository());

class FounderRepository {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://localhost:5000/api/founder',
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 3),
  ));
  final _storage = const FlutterSecureStorage();

  Future<String?> _getToken() async {
    return await _storage.read(key: 'jwt_token');
  }

  Future<Map<String, dynamic>> getProfile() async {
    final token = await _getToken();
    final res = await _dio.get('/profile', options: Options(
      headers: {'Authorization': 'Bearer $token'},
    ));
    return res.data['profile'] ?? {};
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    final token = await _getToken();
    final res = await _dio.put('/profile', data: data, options: Options(
      headers: {'Authorization': 'Bearer $token'},
    ));
    return res.data['profile'] ?? {};
  }
}
