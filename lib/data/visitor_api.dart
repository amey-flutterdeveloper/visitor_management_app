import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/visitor.dart';

class VisitorApi {
  VisitorApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const String _configuredUrl = String.fromEnvironment(
    'VISITOR_API_BASE_URL',
    defaultValue: 'https://6ae03e448e42963c8d5f305b.mockapi.io/api/v1',
  );

  static const Duration _timeout = Duration(seconds: 15);

  String get baseUrl => _configuredUrl.trim().replaceFirst(RegExp(r'/+$'), '');

  Uri _uri([String? id]) {
    if (baseUrl.isEmpty) {
      throw const ApiException(
        'API URL is not configured. '
        'Set VISITOR_API_BASE_URL before running the app.',
      );
    }

    final visitorPath =
        id == null ? 'visitors' : 'visitors/${Uri.encodeComponent(id)}';

    return Uri.parse('$baseUrl/$visitorPath');
  }

  Map<String, String> get _headers => const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  Future<List<Visitor>> getVisitors() async {
    final response =
        await _client.get(_uri(), headers: _headers).timeout(_timeout);

    _check(response);

    final decoded = _decodeJson(response.body);

    if (decoded is! List) {
      throw const ApiException(
        'Unexpected visitor list response from API.',
      );
    }

    try {
      return decoded.map((item) {
        if (item is! Map) {
          throw const ApiException(
            'Invalid visitor record received from API.',
          );
        }

        return Visitor.fromJson(Map<String, dynamic>.from(item));
      }).toList();
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException(
        'Unable to read visitor records returned by API.',
      );
    }
  }

  Future<Visitor> getVisitor(String id) async {
    final response =
        await _client.get(_uri(id), headers: _headers).timeout(_timeout);

    _check(response);

    return _parseVisitor(response.body);
  }

  Future<Visitor> createVisitor(Visitor visitor) async {
    final body = visitor.toJson()..remove('id');

    final response = await _client
        .post(
          _uri(),
          headers: _headers,
          body: jsonEncode(body),
        )
        .timeout(_timeout);

    _check(response);

    return _parseVisitor(response.body);
  }

  Future<Visitor> updateVisitor(Visitor visitor) async {
    final response = await _client
        .put(
          _uri(visitor.id),
          headers: _headers,
          body: jsonEncode(visitor.toJson()),
        )
        .timeout(_timeout);

    _check(response);

    return _parseVisitor(response.body);
  }

  Future<void> deleteVisitor(String id) async {
    final response = await _client
        .delete(
          _uri(id),
          headers: _headers,
        )
        .timeout(_timeout);

    _check(response, allowEmpty: true);
  }

  Visitor _parseVisitor(String body) {
    final decoded = _decodeJson(body);

    if (decoded is! Map) {
      throw const ApiException(
        'Unexpected visitor response from API.',
      );
    }

    try {
      return Visitor.fromJson(Map<String, dynamic>.from(decoded));
    } catch (_) {
      throw const ApiException(
        'Unable to read visitor details returned by API.',
      );
    }
  }

  dynamic _decodeJson(String body) {
    try {
      return jsonDecode(body);
    } on FormatException {
      throw const ApiException(
        'The API returned an invalid JSON response.',
      );
    }
  }

  void _check(
    http.Response response, {
    bool allowEmpty = false,
  }) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    if (allowEmpty && response.statusCode == 204) {
      return;
    }

    var message = 'Request failed (${response.statusCode}).';

    if (response.body.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(response.body);

        if (decoded is Map && decoded['message'] != null) {
          message = decoded['message'].toString();
        }
      } catch (_) {}
    }

    throw ApiException(message);
  }

  void dispose() {
    _client.close();
  }
}

class ApiException implements Exception {
  const ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
