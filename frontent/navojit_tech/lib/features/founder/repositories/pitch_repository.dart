import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PitchRepository {
  final Dio _dio;
  final FlutterSecureStorage _secureStorage;

  // Use the IPv4 address for physical device testing
  static const String _baseUrl = 'http://10.180.96.80:5000/api/pitches';

  PitchRepository()
      : _dio = Dio(BaseOptions(
          baseUrl: _baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        )),
        _secureStorage = const FlutterSecureStorage();

  Future<Map<String, dynamic>> createPitch(Map<String, dynamic> pitchData) async {
    try {
      final token = await _secureStorage.read(key: 'jwt_token');
      if (token == null) throw Exception('Authentication token missing');

      final formData = FormData();
      
      for (final entry in pitchData.entries) {
        if (entry.key == 'pitchDeck' || entry.key == 'executiveSummary') {
          if (entry.value != null && entry.value.toString().isNotEmpty) {
            formData.files.add(MapEntry(
              entry.key,
              await MultipartFile.fromFile(entry.value.toString()),
            ));
          }
        } else {
          formData.fields.add(MapEntry(entry.key, entry.value.toString()));
        }
      }

      final response = await _dio.post(
        '/',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      return response.data;
    } on DioException catch (e) {
      if (e.response != null && e.response?.data['message'] != null) {
        throw Exception(e.response?.data['message']);
      }
      throw Exception('Failed to create pitch');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<List<dynamic>> fetchMyPitches() async {
    try {
      final token = await _secureStorage.read(key: 'jwt_token');
      if (token == null) throw Exception('Authentication token missing');

      final response = await _dio.get(
        '/me',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.data == null) return [];
      
      // Handle root map conversion safely by forcing deep serialization
      final Map<String, dynamic> responseMap = jsonDecode(jsonEncode(response.data)) as Map<String, dynamic>;
      final List<dynamic> rawList = responseMap['data'] ?? responseMap['pitches'] ?? [];
      
      return rawList.map((item) {
        return Map<String, dynamic>.from(item as Map);
      }).toList();
    } on DioException catch (e) {
      // 404 means no pitch submitted yet, return empty list
      if (e.response?.statusCode == 404) {
        return [];
      }
      if (e.response != null && e.response?.data['message'] != null) {
        throw Exception(e.response?.data['message']);
      }
      throw Exception('Failed to fetch pitch');
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
