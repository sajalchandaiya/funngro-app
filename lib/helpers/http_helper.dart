import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_exception.dart';

/// All our CRUD calls go through here.
/// Usage: `final HttpHelper _http = HttpHelper();` then `await _http.get('/path')`.
class HttpHelper {
  HttpHelper({this.url = 'https://api.funngro.example'});

  final String url;
  static const Duration _timeout = Duration(seconds: 15);

  /// One client shared by every HttpHelper instance, so connections are reused.
  /// main.dart swaps this for a fake client in the demo build.
  static http.Client client = http.Client();

  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Future<dynamic> get(String path) {
    return _send(() => client.get(_uri(path), headers: _headers));
  }

  Future<dynamic> post(String path, Map<String, dynamic> body) {
    return _send(
      () => client.post(_uri(path), headers: _headers, body: jsonEncode(body)),
    );
  }

  Future<dynamic> put(String path, Map<String, dynamic> body) {
    return _send(
      () => client.put(_uri(path), headers: _headers, body: jsonEncode(body)),
    );
  }

  Future<dynamic> delete(String path) {
    return _send(() => client.delete(_uri(path), headers: _headers));
  }

  Uri _uri(String path) => Uri.parse('$url$path');

  /// Sends the request, then either returns the decoded JSON or throws ApiException.
  /// Callers only ever have to catch one exception type.
  Future<dynamic> _send(Future<http.Response> Function() request) async {
    final http.Response response;
    try {
      response = await request().timeout(_timeout);
    } on TimeoutException {
      throw ApiException('Request timed out');
    } catch (_) {
      throw ApiException('No internet connection');
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response.body.isEmpty ? null : jsonDecode(response.body);
    }
    throw ApiException('Server error (${response.statusCode})');
  }
}
