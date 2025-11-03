import 'package:dio/dio.dart';

Map<String, String> _parseSetCookie(List<String> setCookies) {
  final map = <String, String>{};
  for (final sc in setCookies) {
    final semi = sc.split(';');
    if (semi.isEmpty) continue;
    final kv = semi.first.split('=');
    if (kv.length < 2) continue;
    final name = kv[0].trim();
    final value = kv.sublist(1).join('=').trim();
    if (name.isEmpty) continue;
    map[name] = value;
  }
  return map;
}

Future<Map<String, String>> refreshCsrf(String rootBaseUrl, String csrfPath) async {
  final d = Dio(BaseOptions(
    baseUrl: rootBaseUrl,
    headers: {'Accept': 'application/json'},
    connectTimeout: const Duration(milliseconds: 5000),
    receiveTimeout: const Duration(milliseconds: 3000),
    followRedirects: false,
  ));
  final resp = await d.get(csrfPath);
  final setCookies = resp.headers.map['set-cookie'] ?? const <String>[];
  final cookies = _parseSetCookie(setCookies);
  final token = cookies['XSRF-TOKEN'];
  if (token != null) cookies['XSRF-TOKEN'] = Uri.decodeComponent(token);
  return cookies;
}
