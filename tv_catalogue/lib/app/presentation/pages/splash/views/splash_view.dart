import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../domain/repositories/authentication_respository.dart';
import '../../../../domain/repositories/connectivity_respository.dart';
import '../../../routes/routes.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    // To know if the widget is rendered at least once
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _init();
    });
  }

  Future<void> _init() async {
    final connectivityRepo = context.read<ConnectivityRepository>();
    final authRepo = context.read<AuthenticationRepository>();
    final hasInternet = await connectivityRepo.hasInternet;
    print('Has internet = $hasInternet 🛜');
    if (hasInternet) {
      final isSignedIn = await authRepo.isSignedIn;
      if (isSignedIn) {
        final user = await authRepo.getUserData();
        if (mounted) {
          if (user != null) {
            _goTo(Routes.home);
          } else {
            _goTo(Routes.signIn);
          }
        }
      }
      // "mounted" to knok if the widget cotinue rendered
      else if (mounted) {
        _goTo(Routes.signIn);
      }
    } else {
      _goTo(Routes.offLine);
    }
  }

  void _goTo(String route) {
    Navigator.pushReplacementNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: SizedBox(
          width: 80,
          height: 80,
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
