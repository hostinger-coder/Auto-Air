import 'package:dio/dio.dart';
import 'dart:html' as html;

String? _readCookie(String name) {
  final cookies = html.document.cookie?.split(';') ?? const [];
  for (final raw in cookies) {
    final idx = raw.indexOf('=');
    if (idx == -1) continue;
    final k = raw.substring(0, idx).trim();
    final v = raw.substring(idx + 1);
    if (k.toLowerCase() == name.toLowerCase()) return Uri.decodeComponent(v);
  }
  return null;
}

Future<Map<String, String>> refreshCsrf(String rootBaseUrl, String csrfPath) async {
  final d = Dio(BaseOptions(
    baseUrl: rootBaseUrl,
    headers: {'Accept': 'application/json'},
    connectTimeout: const Duration(milliseconds: 5000),
    receiveTimeout: const Duration(milliseconds: 3000),
  ));
  await d.get(csrfPath);
  final xsrf = _readCookie('XSRF-TOKEN') ?? '';
  final session = _readCookie('laravel_session') ?? _readCookie('synx_session') ?? '';
  final map = <String, String>{};
  if (xsrf.isNotEmpty) map['XSRF-TOKEN'] = xsrf;
  if (session.isNotEmpty) map['laravel_session'] = session;
  return map;
}
