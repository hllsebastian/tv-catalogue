import '../../domain/models/user.dart';
import '../../domain/repositories/authentication_respository.dart';

class AuthenticationRepositoryImpl implements AuthenticationRepository {
  @override
  Future<bool> get isSignedIn => Future.value(true);

  @override
  Future<User?> getUserData() => Future.value(null);
}
