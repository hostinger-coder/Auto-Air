import 'package:flutter/material.dart';
import 'package:AutoAir/providers/device_provider.dart';
import 'package:AutoAir/features/devices/models/device_model.dart';
import 'package:AutoAir/features/dashboard/models/relay_model.dart';
import 'package:AutoAir/api/api_service.dart';

class DashboardProvider with ChangeNotifier {
  final DeviceProvider _deviceProvider;
  final ApiService _apiService = ApiService();

  bool _isLoading = true;
  String? _error;
  Device? _selectedDevice;

  double? _temperature;
  double? _humidity;
  double? _heatIndex;

  String _mode = '...';
  double _totalKwh = 0.0;
  bool _isPowerOn = false;

  List<Relay> _relays = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  Device? get selectedDevice => _selectedDevice;
  double? get temperature => _temperature;
  double? get humidity => _humidity;
  double? get heatIndex => _heatIndex;
  String get mode => _mode;
  double get totalKwh => _totalKwh;
  bool get isPowerOn => _isPowerOn;
  List<Relay> get relays => _relays;

  DashboardProvider(this._deviceProvider) {
    _deviceProvider.addListener(_onDeviceChanged);
    _selectedDevice = _deviceProvider.selectedDevice;
    if (_selectedDevice != null) {
      _fetchDashboardData();
    }
  }

  @override
  void dispose() {
    _deviceProvider.removeListener(_onDeviceChanged);
    super.dispose();
  }

  void _onDeviceChanged() {
    if (_deviceProvider.selectedDevice != _selectedDevice) {
      _selectedDevice = _deviceProvider.selectedDevice;
      if (_selectedDevice != null) {
        _fetchDashboardData();
      } else {
        _clearData();
      }
    }
  }

  void _clearData() {
    _isLoading = true;
    _relays = [];
    _temperature = null;
    _humidity = null;
    _heatIndex = null;
    _mode = '...';
    _totalKwh = 0.0;
    _isPowerOn = false;
    notifyListeners();
  }

  Future<void> _fetchDashboardData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    if (_selectedDevice == null) {
      _error = "No device selected.";
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      _temperature = 24.0;
      _humidity = 48.0;
      _heatIndex = 25.0;
      _mode = "Auto";
      _totalKwh = 48.0;
      _isPowerOn = false;
      _relays = [
        Relay(id: 1, name: 'Relay 1', amperage: 12.34, isOn: false),
        Relay(id: 2, name: 'Relay 2', amperage: 56.78, isOn: true),
        Relay(id: 3, name: 'Relay 3', amperage: 0.00, isOn: false),
      ];
    } catch (e) {
      _error = "Failed to load dashboard data.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleRelay(int relayId, bool newState) async {
    if (_selectedDevice == null) return;

    final originalStates = _relays.map((r) => r.isOn).toList();

    if (newState) {
      for (var relay in _relays) {
        relay.isOn = (relay.id == relayId);
      }
    } else {
      final relayIndex = _relays.indexWhere((r) => r.id == relayId);
      if (relayIndex != -1) {
        _relays[relayIndex].isOn = false;
      }
    }
    notifyListeners();

    final Map<String, dynamic> relaysPayload = {
      for (var relay in _relays)
        relay.id.toString(): {'is_on': relay.isOn}
    };

    try {
      await _apiService.updateDevice(
        serialNumber: _selectedDevice!.serialNumber,
        data: {
          'config': {'relays': relaysPayload}
        },
      );
    } catch (e) {
      for (int i = 0; i < _relays.length; i++) {
        _relays[i].isOn = originalStates[i];
      }
      _error = "Failed to update relay state.";
      notifyListeners();
    }
  }
}