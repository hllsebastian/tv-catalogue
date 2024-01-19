import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:http/http.dart';

import '../../domain/repositories/either.dart';

part 'failure.dart';
part 'parse_response_body.dart';
part 'logs.dart';

enum HttpMethod { get, post, patch, put, delete }

class Http {
  Http({
    required Client client,
    required String baseUrl,
    required String apiKey,
  })  : _client = client,
        _baseUrl = baseUrl,
        _apiKey = apiKey;

  final Client _client;
  final String _baseUrl;
  final String _apiKey;

  Future<Either<HttpFailure, R>> request<R>(
    String path, {
    required R Function(dynamic responseBody) onSuccess,
    HttpMethod method = HttpMethod.get,
    Map<String, String> headers = const {},
    Map<String, String> queryParameters = const {},
    Map<String, String> body = const {},
    final bool useApiKey = true,
  }) async {
    Map<String, dynamic> logs = {};
    StackTrace? stackTrace;
    try {
      if (useApiKey) {
        queryParameters = {
          ...queryParameters,
          'api_key': _apiKey,
        };
      }
      Uri url = Uri.parse(path.startsWith('http') ? path : '$_baseUrl$path');
      if (queryParameters.isNotEmpty) {
        url = url.replace(queryParameters: queryParameters);
      }
      headers = {'Content-Type': 'application/json', ...headers};
      final bodyString = jsonEncode(body);
      late final Response response;

      logs = {
        'starTime': DateTime.now().toString(),
        'url': url.toString(),
        'method': method.name,
        'body': body,
      };

      switch (method) {
        case HttpMethod.get:
          response = await _client.get(url);
          break;
        case HttpMethod.post:
          response = await _client.post(
            url,
            headers: headers,
            body: bodyString,
          );
          break;
        case HttpMethod.patch:
          response = await _client.patch(
            url,
            headers: headers,
            body: bodyString,
          );
          break;
        case HttpMethod.put:
          response = await _client.put(
            url,
            headers: headers,
            body: bodyString,
          );
          break;
        case HttpMethod.delete:
          response = await _client.delete(
            url,
            headers: headers,
            // body: bodyString,
          );
          break;
      }

      final statusCode = response.statusCode;
      logs = {
        ...logs,
        'statusCode': statusCode,
        'responseBody': _parseResponseBody(response.body),
      };

      if (statusCode >= 200 && statusCode < 300) {
        final responseBody = _parseResponseBody(response.body);
        return Either.right(onSuccess(responseBody));
      }
      return Either.left(HttpFailure(statuscode: statusCode));
    } catch (e, s) {
      stackTrace = s;
      logs = {
        ...logs,
        'exception': e.runtimeType,
        // 'strackTrace':
        //     stackTrace.toString(),
      };
      // SocketException for mobile, ClientException for web (doesn't has internet)
      if (e is SocketException || e is ClientException) {
        logs = {...logs, 'exception': 'NetWork Exception'};
        // print(logs);
        return Either.left(
          HttpFailure(
            exception: NetworkException(),
          ),
        );
      }
      // print(logs);
      return Either.left(
        HttpFailure(
          exception: e,
        ),
      );
    } finally {
      logs = {...logs, 'endTime': DateTime.now().toString()};
      _printLogs(logs, stackTrace);
    }
  }
}
