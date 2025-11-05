// ===== lib/api/api_service.dart =====

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../navigation_service.dart';
import '../features/profile/models/user_model.dart';
import '../features/dashboard/models/schedule_model.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ApiService {
  final Dio _dio;
  final FlutterSecureStorage _secureStorage;
  final DeviceInfoPlugin _deviceInfoPlugin;

  static const String _baseUrl = 'http://192.168.0.56:8001/api/v1/';
  static const String _tokenKey = 'auth_token';

  static final ApiService _instance = ApiService._internal();

  factory ApiService() {
    return _instance;
  }

  ApiService._internal()
      : _dio = Dio(),
        _secureStorage = const FlutterSecureStorage(),
        _deviceInfoPlugin = DeviceInfoPlugin() {
    _dio.options = BaseOptions(
      baseUrl: _baseUrl,
      headers: {'Accept': 'application/json'},
      connectTimeout: const Duration(milliseconds: 15000),
      receiveTimeout: const Duration(milliseconds: 15000),
      validateStatus: (status) {
        return status != null && status < 500;
      },
    );

    _dio.interceptors.add(_createInterceptorsWrapper());
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(responseBody: true, requestBody: true));
    }
  }

  InterceptorsWrapper _createInterceptorsWrapper() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _secureStorage.read(key: _tokenKey);
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (e, handler) async {
        if (e.response?.statusCode == 401) {
          await _handleUnauthorized();
          return;
        }
        return handler.next(e);
      },
    );
  }

  Future<void> _handleUnauthorized() async {
    await _secureStorage.delete(key: _tokenKey);
    navigatorKey.currentState?.pushNamedAndRemoveUntil('/login', (route) => false);
  }

  dynamic _processResponse(Response response) {
    final responseData = response.data;
    if (response.statusCode == 200 || response.statusCode == 201) {
      if (responseData is Map<String, dynamic> && responseData['success'] == false) {
        throw ApiException(responseData['message'] ?? 'An unknown error occurred.', statusCode: response.statusCode);
      }
      return responseData['data'] ?? responseData;
    } else if (response.statusCode == 422) {
      final errors = responseData['errors'];
      final message = errors is Map ? errors.values.first[0] : responseData['message'];
      throw ApiException(message ?? 'Invalid data provided.', statusCode: 422);
    } else {
      final message = responseData is Map ? responseData['message'] : 'An unexpected error occurred.';
      throw ApiException(message, statusCode: response.statusCode);
    }
  }

  Never _handleDioException(DioException e) {
    if (e.response != null) {
      throw ApiException(e.response?.data['message'] ?? 'Server error', statusCode: e.response?.statusCode);
    } else {
      throw ApiException('Network error. Please check your connection.', statusCode: e.response?.statusCode);
    }
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
      final response = await _dio.post(
        'auth/mobile/login',
        data: {'email': email, 'password': password, 'device_name': await _getDeviceName()},
      );
      final responseData = _processResponse(response);
      await _secureStorage.write(key: _tokenKey, value: responseData['token']);
    } on DioException catch (e) {
      _handleDioException(e);
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
      final response = await _dio.post(
        'auth/mobile/register',
        data: {
          'first_name': firstName,
          'last_name': lastName,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
          'device_name': await _getDeviceName(),
        },
      );
      final responseData = _processResponse(response);
      await _secureStorage.write(key: _tokenKey, value: responseData['token']);
    } on DioException catch (e) {
      _handleDioException(e);
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post('auth/mobile/logout');
    } catch (_) {
    } finally {
      await _secureStorage.delete(key: _tokenKey);
    }
  }

  Future<User?> authenticate() async {
    try {
      final response = await _dio.get('auth/mobile/authenticate');
      final responseData = _processResponse(response);
      if (responseData != null) {
        return User.fromJson(responseData);
      }
      return null;
    } on DioException {
      return null;
    } on ApiException {
      return null;
    }
  }

  Future<void> forgotPassword({required String email}) async {
    try {
      final response = await _dio.post('auth/mobile/forgot-password', data: {'email': email});
      _processResponse(response);
    } on DioException catch (e) {
      _handleDioException(e);
    }
  }

  Future<User> updateUserProfile({required String userId, required Map<String, dynamic> data}) async {
    try {
      final response = await _dio.patch('users/$userId', data: data);
      return User.fromJson(_processResponse(response));
    } on DioException catch (e) {
      _handleDioException(e);
    }
  }

  Future<void> changePassword({
    required String userId,
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    try {
      final response = await _dio.patch('users/$userId/password', data: {
        'current_password': currentPassword,
        'password': newPassword,
        'password_confirmation': newPasswordConfirmation,
      });
      _processResponse(response);
    } on DioException catch (e) {
      _handleDioException(e);
    }
  }

  Future<List<dynamic>> getDevices({Map<String, dynamic>? params}) async {
    try {
      final response = await _dio.get('devices', queryParameters: params);
      final responseData = _processResponse(response);
      if (responseData is Map<String, dynamic> && responseData['data'] is List) {
        return List<dynamic>.from(responseData['data']);
      }
      throw ApiException('Invalid response format for devices.');
    } on DioException catch (e) {
      _handleDioException(e);
    }
  }

  Future<Map<String, dynamic>> createDevice({
    required String name,
    required String serialNumber,
    required String pin,
    String? description,
  }) async {
    try {
      final response = await _dio.post('devices', data: {
        'name': name,
        'serial_number': serialNumber,
        'pin': pin,
        if (description != null) 'description': description,
      });
      return Map<String, dynamic>.from(_processResponse(response));
    } on DioException catch (e) {
      _handleDioException(e);
    }
  }

  Future<Map<String, dynamic>> updateDevice({
    required String serialNumber,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await _dio.patch('devices/$serialNumber', data: data);
      return Map<String, dynamic>.from(_processResponse(response));
    } on DioException catch (e) {
      _handleDioException(e);
    }
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
    try {
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
    } on DioException catch (e) {
      _handleDioException(e);
    }
  }

  Future<void> updateDeviceTimeConfig({
    required String deviceSerialNumber,
    required String isoTime,
    required String timezone,
  }) async {
    try {
      await _dio.patch('devices/$deviceSerialNumber', data: {
        'config': {
          'time': {'datetime': isoTime, 'timezone': timezone}
        }
      });
    } on DioException catch (e) {
      _handleDioException(e);
    }
  }

  Future<List<RelaySchedule>> getSchedules({
    required String deviceSerialNumber,
    required String relayId,
  }) async {
    try {
      final response = await _dio.get('devices/$deviceSerialNumber/relays/$relayId/schedules');
      final responseData = _processResponse(response);
      final scheduleList = (responseData['data'] as List).cast<Map<String, dynamic>>();
      return scheduleList.map((json) => RelaySchedule.fromJson(json)).toList();
    } on DioException catch (e) {
      _handleDioException(e);
    }
  }

  Future<RelaySchedule> createSchedule({
    required String deviceSerialNumber,
    required String relayId,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await _dio.post('devices/$deviceSerialNumber/relays/$relayId/schedules', data: data);
      return RelaySchedule.fromJson(_processResponse(response));
    } on DioException catch (e) {
      _handleDioException(e);
    }
  }

  Future<RelaySchedule> updateSchedule({
    required String deviceSerialNumber,
    required String relayId,
    required String scheduleId,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await _dio.patch('devices/$deviceSerialNumber/relays/$relayId/schedules/$scheduleId', data: data);
      return RelaySchedule.fromJson(_processResponse(response));
    } on DioException catch (e) {
      _handleDioException(e);
    }
  }

  Future<void> deleteSchedule({
    required String deviceSerialNumber,
    required String relayId,
    required String scheduleId,
  }) async {
    try {
      await _dio.delete('devices/$deviceSerialNumber/relays/$relayId/schedules/$scheduleId');
    } on DioException catch (e) {
      _handleDioException(e);
    }
  }
}