import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../domain/enums.dart';
import '../../domain/models/user.dart';
import '../../domain/repositories/authentication_respository.dart';
import '../../domain/repositories/either.dart';
import '../services/remote/authentication_api.dart';

const _key = 'sessionId';

class AuthenticationRepositoryImpl implements AuthenticationRepository {
  AuthenticationRepositoryImpl(this._secureStorage, this._authenticationApi);
  final FlutterSecureStorage _secureStorage;
  final AuthenticationApi _authenticationApi;

  @override
  Future<bool> get isSignedIn async {
    final sessionId = await _secureStorage.read(key: _key);
    return sessionId != null;
  }

  @override
  Future<User?> getUserData() => Future.value(User());

  @override
  Future<Either<SingInFailure, User>> signIn(
    String userName,
    String password,
  ) async {
    final requestTokenResult = await _authenticationApi.createRequestToken();

    return requestTokenResult.when(
      (failure) => Either.left(failure),
      (requestToken) async {
        final loginResult = await _authenticationApi.createSessionWithLogin(
          userName: userName,
          password: password,
          requestToken: requestToken,
        );

        return loginResult.when((failure) async => Either.left(failure), (
          newRequestToken,
        ) async {
          final sessionResult = await _authenticationApi.createSessionId(
            newRequestToken,
          );

          return sessionResult.when((failure) async => Either.left(failure),
              (sessionId) async {
            await _secureStorage.write(key: _key, value: sessionId);
            return Either.right(User());
          });
        });
      },
    );
  }

  @override
  Future<void> signOut() {
    return _secureStorage.delete(key: _key);
  }
}
