import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:AutoAir/api/api_service.dart';
import 'package:AutoAir/features/devices/models/device_model.dart';

class DeviceProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  static const _activeDeviceKey = 'active_device_serial';

  List<Device> _devices = [];
  Device? _selectedDevice;
  bool _isLoading = false;
  String? _error;

  List<Device> get devices => _devices;
  Device? get selectedDevice => _selectedDevice;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void selectDevice(Device? device) {
    if (_selectedDevice != device) {
      _selectedDevice = device;
      notifyListeners();
    }
  }

  Future<void> persistActiveDevice(Device device) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_activeDeviceKey, device.serialNumber);
    selectDevice(device);
  }

  Future<void> clearActiveDevice() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_activeDeviceKey);
  }

  Future<bool> loadInitialDevice() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final serial = prefs.getString(_activeDeviceKey);
      if (serial == null || serial.isEmpty) return false;

      await fetchDevices();
      final activeDevice = _devices.firstWhere((d) => d.serialNumber == serial);
      _selectedDevice = activeDevice;
      notifyListeners();
      return true;
    } catch (e) {
      await clearActiveDevice();
      return false;
    }
  }

  Future<void> fetchDevices() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final deviceData = await _apiService.getDevices();
      _devices = deviceData.map((data) => Device.fromJson(data)).toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addDevice({
    required String name,
    required String serialNumber,
    required String pin,
    String? description,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _apiService.createDevice(
        name: name,
        serialNumber: serialNumber,
        pin: pin,
        description: description,
      );
      await fetchDevices();
    } on DioException catch (e) {
      String errorMessage = "Failed to add device. Please try again.";
      if (e.response?.data is Map && e.response!.data['message'] != null) {
        String serverMessage = e.response!.data['message'];
        if (serverMessage.contains('COMFAC service')) {
          errorMessage = "An unexpected server error occurred. Please try again later.";
        } else {
          errorMessage = serverMessage;
        }
      }
      _error = errorMessage;
      notifyListeners();
      throw Exception(errorMessage);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}