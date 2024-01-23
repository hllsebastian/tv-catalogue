import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'app/data/http/http.dart';

import 'app/data/repositories_impl/authentication_repository_impl.dart';
import 'app/data/repositories_impl/connectivity_repository_impl.dart';
import 'app/data/services/remote/authentication_api.dart';
import 'app/data/services/remote/internet_checker.dart';
import 'app/domain/repositories/authentication_respository.dart';
import 'app/domain/repositories/connectivity_respository.dart';

List<SingleChildWidget> providers = [
  Provider<ConnectivityRepository>(
    create: (_) {
      return ConnectivityRepositoryImpl(
        Connectivity(),
        InternetChecker(),
      );
    },
  ),
  Provider<AuthenticationRepository>(
    create: (_) {
      return AuthenticationRepositoryImpl(
        const FlutterSecureStorage(),
        AuthenticationApi(
          Http(
            client: http.Client(),
            baseUrl: 'https://api.themoviedb.org/3',
          ),
        ),
      );
    },
  )
];
