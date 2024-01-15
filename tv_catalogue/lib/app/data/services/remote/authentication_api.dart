import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';

import '../../../domain/enums.dart';
import '../../../domain/repositories/either.dart';

class AuthenticationApi {
  AuthenticationApi(this._client);
  final Client _client;
  final _baseUrl = 'https://api.themoviedb.org/3';

  Future<String?> createRequestToken() async {
    try {
      Map<String, dynamic> jsonResponse = {};
      final response = await _client.get(
        Uri.parse('$_baseUrl/authentication/token/new?$_apiKey'),
      );

      print('🔥 STATUS CODE: ${response.statusCode}');
      print('🔥 BODY: ${response.body}');

      if (response.statusCode == 200) {
        jsonResponse = Map<String, dynamic>.from(jsonDecode(response.body));
      }
      return jsonResponse['request_token'];
    } catch (e) {
      print('🔥 ERROR: $e');
      return e as String;
    }
  }

  Future<Either<SingInFailure, String>> createSessionWithLogin({
    required String userName,
    required String password,
    required String requestToken,
  }) async {
    try {
      Map<String, dynamic> jsonResponse = {};
      final String newRequestToken;
      final response = await _client.post(
        Uri.parse(
            '$_baseUrl/authentication/token/validate_with_login?$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': userName,
          'password': password,
          'request_token': requestToken
        }),
      );

      switch (response.statusCode) {
        case 200:
          jsonResponse = Map<String, dynamic>.from(jsonDecode(response.body));
          newRequestToken = jsonResponse['request_token'] as String;
          return Either.right(newRequestToken);
        case 401:
          return Either.left(SingInFailure.unauthorized);
        case 404:
          return Either.left(SingInFailure.notFound);
        default:
          return Either.left(SingInFailure.unknown);
      }
    } catch (e) {
      if (e is SocketException) {
        return Either.left(SingInFailure.network);
      }
      return Either.left(SingInFailure.unknown);
    }
  }

  Future<Either<SingInFailure, String>> createSessionId(
    String requestToken,
  ) async {
    try {
      late String sessionId;
      Map<String, dynamic> jsonResponse = {};
      final response = await _client.post(
        Uri.parse('$_baseUrl/authentication/session/new?$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'request_token': requestToken}),
      );
      if (response.statusCode == 200) {
        jsonResponse = Map<String, dynamic>.from(jsonDecode(response.body));
        sessionId = jsonResponse['session_id'] as String;
        return Either.right(sessionId);
      }
      return Either.left(SingInFailure.unknown);
    } catch (e) {
      if (e is SocketException) {
        return Either.left(SingInFailure.network);
      }
      return Either.left(SingInFailure.unknown);
    }
  }
}
