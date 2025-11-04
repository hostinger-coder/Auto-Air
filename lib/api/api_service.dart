// ===== lib/api/api_service.dart =====

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../navigation_service.dart';

class ApiService {
  final Dio _dio;
  final FlutterSecureStorage _secureStorage;
  final DeviceInfoPlugin _deviceInfoPlugin;

  static const String _baseUrl = 'http://192.168.0.56:8001/api/v1/';
  static const String _tokenKey = 'auth_token';

  ApiService._()
      : _dio = Dio(),
        _secureStorage = const FlutterSecureStorage(),
        _deviceInfoPlugin = DeviceInfoPlugin() {
    _dio.options = BaseOptions(
      baseUrl: _baseUrl,
      headers: {'Accept': 'application/json'},
      connectTimeout: const Duration(milliseconds: 15000),
      receiveTimeout: const Duration(milliseconds: 15000),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _secureStorage.read(key: _tokenKey);
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (e, handler) async {
          if (e.response?.statusCode == 401) {
            await _secureStorage.delete(key: _tokenKey);
            navigatorKey.currentState
                ?.pushNamedAndRemoveUntil('/login', (route) => false);
            return;
          }
          return handler.next(e);
        },
      ),
    );

    _dio.interceptors.add(LogInterceptor(responseBody: true, requestBody: true));
  }

  static final ApiService _instance = ApiService._();

  factory ApiService() {
    return _instance;
  }

  Future<String> _getDeviceName() async {
    try {
      if (kIsWeb) {
        final webBrowserInfo = await _deviceInfoPlugin.webBrowserInfo;
        return webBrowserInfo.browserName.name;
      } else if (Platform.isAndroid) {
        final androidInfo = await _deviceInfoPlugin.androidInfo;
        return androidInfo.model ?? 'Android';
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfoPlugin.iosInfo;
        return iosInfo.model ?? 'iOS';
      }
    } catch (_) {}
    return 'Unknown';
  }

  Future<void> login({required String email, required String password}) async {
    try {
      final deviceName = await _getDeviceName();
      final response = await _dio.post(
        'auth/mobile/login',
        data: {'email': email, 'password': password, 'device_name': deviceName},
      );
      final responseData = response.data['data'];
      if (response.statusCode == 200 && responseData['token'] != null) {
        await _secureStorage.write(key: _tokenKey, value: responseData['token']);
      } else {
        throw Exception('Login failed');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 422) {
        throw Exception('Invalid credentials');
      }
      throw Exception('Network error');
    }
  }

  Future<void> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final deviceName = await _getDeviceName();
      final response = await _dio.post(
        'auth/mobile/register',
        data: {
          'first_name': firstName,
          'last_name': lastName,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
          'device_name': deviceName,
        },
      );
      final responseData = response.data['data'];
      if (response.statusCode == 200 && responseData['token'] != null) {
        await _secureStorage.write(key: _tokenKey, value: responseData['token']);
      } else {
        throw Exception('Registration failed');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 422) {
        throw Exception('Invalid data');
      }
      throw Exception('Network error');
    }
  }

  Future<void> forgotPassword({required String email}) async {
    try {
      await _dio.post('auth/mobile/forgot-password', data: {'email': email});
    } on DioException catch (e) {
      if (e.response?.statusCode == 422) {
        throw Exception('Invalid email');
      }
      throw Exception('Network error');
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post('auth/mobile/logout');
    } catch (_) {} finally {
      await _secureStorage.delete(key: _tokenKey);
    }
  }

  Future<bool> authenticate() async {
    try {
      final response = await _dio.get('auth/mobile/authenticate');
      return response.statusCode == 200;
    } on DioException {
      return false;
    }
  }

  Future<Map<String, dynamic>> getUser() async {
    try {
      final response = await _dio.get('auth/mobile/user');
      return Map<String, dynamic>.from(response.data['data'] ?? response.data);
    } on DioException {
      throw Exception('Failed to fetch user profile.');
    }
  }

  Future<void> updateUserProfile(Map<String, dynamic> data) async {
    try {
      await _dio.put('auth/mobile/user/profile', data: data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 422) {
        throw Exception('Invalid data provided.');
      }
      throw Exception('Failed to update profile.');
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    try {
      await _dio.put('auth/mobile/user/password', data: {
        'current_password': currentPassword,
        'password': newPassword,
        'password_confirmation': newPasswordConfirmation,
      });
    } on DioException catch (e) {
      if (e.response?.statusCode == 422) {
        throw Exception('Invalid password data.');
      }
      throw Exception('Failed to change password.');
    }
  }

  Future<List<dynamic>> getDevices({Map<String, dynamic>? params}) async {
    final response = await _dio.get('devices', queryParameters: params);
    if (response.data is Map<String, dynamic> &&
        response.data['data'] is Map<String, dynamic> &&
        response.data['data']['data'] is List) {
      return List<dynamic>.from(response.data['data']['data']);
    }
    throw Exception('Invalid response format for devices.');
  }

  Future<Map<String, dynamic>> createDevice({
    required String name,
    required String serialNumber,
    required String pin,
    String? description,
  }) async {
    final response = await _dio.post('devices', data: {
      'name': name,
      'serial_number': serialNumber,
      'pin': pin,
      if (description != null) 'description': description,
    });
    return Map<String, dynamic>.from(response.data is Map<String, dynamic> && response.data['data'] != null ? response.data['data'] : response.data);
  }

  Future<Map<String, dynamic>> updateDevice({
    required String serialNumber,
    required Map<String, dynamic> data,
  }) async {
    final response = await _dio.patch('devices/$serialNumber', data: data);
    return Map<String, dynamic>.from(response.data is Map<String, dynamic> && response.data['data'] != null ? response.data['data'] : response.data);
  }

  Future<void> updateDeviceWifiConfig({
    required String deviceSerialNumber,
    required String ssid,
    required String password,
    bool isStatic = false,
    String? ipAddress,
    String? subnet,
    String? gateway,
  }) async {
    await _dio.patch('devices/$deviceSerialNumber', data: {
      'config': {
        'wifi': {
          'ssid': ssid,
          'password': password,
          'is_static': isStatic,
          if (isStatic) 'ip_address': ipAddress,
          if (isStatic) 'subnet': subnet,
          if (isStatic) 'gateway': gateway,
        }
      }
    });
  }

  Future<void> updateDeviceTimeConfig({
    required String deviceSerialNumber,
    required String isoTime,
    required String timezone,
  }) async {
    await _dio.patch('devices/$deviceSerialNumber', data: {
      'config': {
        'time': {
          'datetime': isoTime,
          'timezone': timezone,
        }
      }
    });
  }
}