import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'app/data/repositories_impl/authentication_repository_impl.dart';
import 'app/data/repositories_impl/connectivity_repository_impl.dart';
import 'app/data/services/remote/authentication_api.dart';
import 'app/data/services/remote/internet_checker.dart';
import 'app/domain/repositories/authentication_respository.dart';
import 'app/domain/repositories/connectivity_respository.dart';
import 'app/my_app.dart';

void main() {
  runApp(Injector(
    connectivityRepo: ConnectivityRepositoryImpl(
      Connectivity(),
      InternetChecker(),
    ),
    authRepo: AuthenticationRepositoryImpl(
        const FlutterSecureStorage(),
        AuthenticationApi(
          http.Client(),
        )),
    child: const MyApp(),
  ));
}

class Injector extends InheritedWidget {
  const Injector({
    super.key,
    required super.child,
    required this.connectivityRepo,
    required this.authRepo,
  });
  final ConnectivityRepository connectivityRepo;
  final AuthenticationRepository authRepo;

  @override
  // ignore: avoid_renaming_method_parameters
  bool updateShouldNotify(_) => false;

  static Injector of(BuildContext context) {
    // To know the widget location by the context
    final injector = context.dependOnInheritedWidgetOfExactType<Injector>();
    // assert(injector == null, 'Injector could not be found');
    return injector!;
  }
}
