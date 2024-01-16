import 'dart:convert';

import '../../../domain/enums.dart';
import '../../../domain/repositories/either.dart';
import '../../http/http.dart';

class AuthenticationApi {
  AuthenticationApi(this._http);
  final Http _http;

  Future<Either<SingInFailure, String>> createRequestToken() async {
    final result = await _http.request('/authentication/token/new');

    return result.when((failure) {
      if (failure.exception is NetworkException) {
        return Either.left(SingInFailure.network);
      }
      print('${failure.exception}****${failure.statuscode}');
      return Either.left(SingInFailure.unknown);
    }, (responseBody) {
      final json = Map<String, dynamic>.from(jsonDecode(responseBody));
      final requestToken = json['request_token'] as String;
      return Either.right(requestToken);
    });
  }

  Future<Either<SingInFailure, String>> createSessionWithLogin({
    required String userName,
    required String password,
    required String requestToken,
  }) async {
    final result = await _http.request(
        '/authentication/token/validate_with_login',
        method: HttpMethod.post,
        body: {
          'username': userName,
          'password': password,
          'request_token': requestToken,
        });

    return result.when(
      (failure) {
        if (failure.statuscode != null) {
          switch (failure.statuscode) {
            case 400:
              return Either.left(SingInFailure.unauthorized);
            case 401:
              return Either.left(SingInFailure.notFound);
            default:
              return Either.left(SingInFailure.unknown);
          }
        }
        if (failure.exception is NetworkException) {
          return Either.left(SingInFailure.network);
        }
        return Either.left(SingInFailure.network);
      },
      (responseBody) {
        final json = Map<String, dynamic>.from(jsonDecode(responseBody));
        final requestToken = json['request_token'] as String;
        return Either.right(requestToken);
      },
    );
  }

  Future<Either<SingInFailure, String>> createSessionId(
    String requestToken,
  ) async {
    final result = await _http.request(
      '/authentication/session/new',
      method: HttpMethod.post,
      body: {'request_token': requestToken},
    );

    return result.when(
      (failure) {
        if (failure.exception is NetworkException) {
          return Either.left(SingInFailure.network);
        }
        return Either.left(SingInFailure.unknown);
      },
      (responseBody) {
        final json = Map<String, dynamic>.from(jsonDecode(responseBody));
        final sessionId = json['session_id'] as String;
        return Either.right(sessionId);
      },
    );
  }
}
