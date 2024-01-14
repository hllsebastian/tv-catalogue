import '../enums.dart';
import '../models/user.dart';
import 'either.dart';

abstract class AuthenticationRepository {
  Future<bool> get isSignedIn;
  Future<User?> getUserData();
  Future<Either<SingInFailure, User>> signIn(String userName, String password);
  Future<void> signOut();
}
