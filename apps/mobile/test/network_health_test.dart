import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

void main() {
  test('Flutter client communicates with live Render backend and MongoDB',
      () async {
    const url = 'https://acedex-api.onrender.com/health';
    final response = await http
        .get(Uri.parse(url))
        .timeout(const Duration(seconds: 15));

    expect(response.statusCode, 200);

    final json = jsonDecode(response.body);
    expect(json['success'], true);
    expect(json['data']['status'], 'healthy');
    expect(json['data']['database']['connected'], true);
    expect(json['data']['database']['name'], 'acedex');
  });
}
