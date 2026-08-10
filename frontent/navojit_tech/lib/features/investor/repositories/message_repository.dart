import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MessageRepository {
  final Dio _dio;
  final FlutterSecureStorage _secureStorage;

  static const String _baseUrl = 'http://localhost:5000/api/messages';

  MessageRepository()
      : _dio = Dio(BaseOptions(
          baseUrl: _baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        )),
        _secureStorage = const FlutterSecureStorage();

  Future<String?> _getToken() async {
    return await _secureStorage.read(key: 'jwt_token');
  }

  Future<List<dynamic>> getConversations() async {
    try {
      final token = await _getToken();
      final response = await _dio.get(
        '/conversations',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data['conversations'] ?? [];
    } catch (e) {
      throw Exception('Failed to load conversations');
    }
  }

  Future<void> sendMessage(String receiverId, String pitchId, String text) async {
    try {
      final token = await _getToken();
      await _dio.post(
        '/send',
        data: {
          'receiverId': receiverId,
          'pitchId': pitchId,
          'text': text,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } catch (e) {
      throw Exception('Failed to send message');
    }
  }
}
