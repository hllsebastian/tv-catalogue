import '../../domain/repositories/connectivity_respository.dart';

class ConnectivityRepositoryImpl implements ConnectivityRepository {
  @override
  Future<bool> get hasInternet async {
    await Future.delayed(const Duration(seconds: 2));
    return Future.value(true);
  }
}
