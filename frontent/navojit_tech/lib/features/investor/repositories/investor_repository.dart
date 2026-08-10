import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:navojit_tech/features/investor/models/startup_deal.dart';

class InvestorRepository {
  final Dio _dio;
  final FlutterSecureStorage _secureStorage;

  static const String _baseUrl = 'http://localhost:5000/api/investor';

  InvestorRepository()
      : _dio = Dio(BaseOptions(
          baseUrl: _baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        )),
        _secureStorage = const FlutterSecureStorage();

  Future<String?> _getToken() async {
    return await _secureStorage.read(key: 'jwt_token');
  }

  Future<void> toggleWatchlist(String pitchId) async {
    try {
      final token = await _getToken();
      await _dio.post(
        '/watchlist/toggle',
        data: {'pitchId': pitchId},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } catch (e) {
      throw Exception('Failed to toggle watchlist');
    }
  }

  Future<List<StartupDeal>> getWatchlist() async {
    try {
      final token = await _getToken();
      final response = await _dio.get(
        '/watchlist',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      final list = response.data['pitches'] as List<dynamic>?;
      if (list == null) return [];
      return list.map((j) => StartupDeal.fromApi(j)).toList();
    } catch (e) {
      throw Exception('Failed to load watchlist');
    }
  }

  Future<void> signNda(String pitchId) async {
    try {
      final token = await _getToken();
      await _dio.post(
        '/nda/sign',
        data: {'pitchId': pitchId},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } catch (e) {
      throw Exception('Failed to sign NDA');
    }
  }

  Future<bool> getNdaStatus(String pitchId) async {
    try {
      final token = await _getToken();
      final response = await _dio.get(
        '/nda/status/$pitchId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data['signed'] == true;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>> getProfile() async {
    try {
      final token = await _getToken();
      final response = await _dio.get(
        '/profile',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data['profile'] ?? {};
    } catch (e) {
      throw Exception('Failed to load profile');
    }
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    try {
      final token = await _getToken();
      await _dio.put(
        '/profile',
        data: data,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } catch (e) {
      throw Exception('Failed to update profile');
    }
  }

  Future<List<dynamic>> getInvestments() async {
    try {
      final token = await _getToken();
      final response = await _dio.get(
        '/investments',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data['investments'] ?? [];
    } catch (e) {
      throw Exception('Failed to load investments');
    }
  }
}
