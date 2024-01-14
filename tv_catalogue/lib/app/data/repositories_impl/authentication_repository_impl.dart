import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../domain/enums.dart';
import '../../domain/models/user.dart';
import '../../domain/repositories/authentication_respository.dart';
import '../../domain/repositories/either.dart';

const _key = 'sessionId';

class AuthenticationRepositoryImpl implements AuthenticationRepository {
  final FlutterSecureStorage _secureStorage;

  AuthenticationRepositoryImpl(this._secureStorage);

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
    await Future.delayed(Duration(seconds: 2));
    if (userName != 'test') {
      return Either.left(SingInFailure.notFound);
    }
    if (password != '123456') {
      return Either.left(SingInFailure.unauthorized);
    }

    await _secureStorage.write(key: _key, value: '123');

    return Either.right(User());
  }

  @override
  Future<void> signOut() {
    return _secureStorage.delete(key: _key);
  }
}
