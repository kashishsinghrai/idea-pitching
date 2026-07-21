import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:navojit_tech/features/investor/models/startup_deal.dart';

class DealFlowRepository {
  final Dio _dio;
  final FlutterSecureStorage _secureStorage;

  // Ensure this points to the physical device's IPv4 or the local loopback for emulators
  static const String _baseUrl = 'http://10.180.96.80:5000/api/pitches';

  DealFlowRepository()
      : _dio = Dio(BaseOptions(
          baseUrl: _baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        )),
        _secureStorage = const FlutterSecureStorage();

  Future<List<StartupDeal>> fetchDealFlow({String? industry, String? stage}) async {
    try {
      final token = await _secureStorage.read(key: 'jwt_token');
      if (token == null) throw Exception('Authentication token missing');

      final queryParams = <String, dynamic>{};
      if (industry != null && industry != 'All') queryParams['industry'] = industry;
      if (stage != null && stage != 'All') queryParams['stage'] = stage;

      final response = await _dio.get(
        '/deal-flow',
        queryParameters: queryParams.isEmpty ? null : queryParams,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      final pitchesList = response.data['pitches'] as List<dynamic>?;
      if (pitchesList == null) return [];

      return pitchesList.map((json) => StartupDeal.fromApi(json)).toList();
    } on DioException catch (e) {
      if (e.response != null && e.response?.data['message'] != null) {
        throw Exception(e.response?.data['message']);
      }
      throw Exception('Failed to fetch deal flow');
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
