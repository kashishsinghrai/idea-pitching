import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthRepository {
  final Dio _dio;
  final FlutterSecureStorage _secureStorage;

  // Since testing on a physical device, use the local IPv4 address
  static const String _baseUrl = 'http://10.180.96.80:5000/api/auth';

  AuthRepository()
      : _dio = Dio(BaseOptions(
          baseUrl: _baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        )),
        _secureStorage = const FlutterSecureStorage();

  /// Registers a new user. Throws an exception if registration fails.
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      final response = await _dio.post('/register', data: {
        'firstName': name.split(' ').first,
        'lastName': name.split(' ').length > 1 ? name.split(' ').last : '',
        'email': email,
        'password': password,
        'role': role.toUpperCase(), // 'FOUNDER' or 'INVESTOR'
      });

      final token = response.data['token'];
      if (token != null) {
        await _secureStorage.write(key: 'jwt_token', value: token);
      }
      
      return response.data;
    } on DioException catch (e) {
      if (e.response != null && e.response?.data['message'] != null) {
        throw Exception(e.response?.data['message']);
      }
      throw Exception('Failed to connect to the server');
    } catch (e) {
      throw Exception('An unexpected error occurred');
    }
  }

  /// Logs in a user. Throws an exception if login fails.
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post('/login', data: {
        'email': email,
        'password': password,
      });

      final token = response.data['token'];
      if (token != null) {
        await _secureStorage.write(key: 'jwt_token', value: token);
      }
      
      return response.data;
    } on DioException catch (e) {
      if (e.response != null && e.response?.data['message'] != null) {
        throw Exception(e.response?.data['message']);
      }
      throw Exception('Failed to connect to the server');
    } catch (e) {
      throw Exception('An unexpected error occurred');
    }
  }

  /// Logs out the user by deleting the stored token
  Future<void> logout() async {
    await _secureStorage.delete(key: 'jwt_token');
  }

  /// Checks if the user is already authenticated
  Future<bool> isAuthenticated() async {
    final token = await _secureStorage.read(key: 'jwt_token');
    return token != null;
  }
}
