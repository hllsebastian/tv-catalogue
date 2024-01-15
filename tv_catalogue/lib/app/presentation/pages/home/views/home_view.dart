import 'package:flutter/material.dart';

import '../../../../../main.dart';
import '../../../routes/routes.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TextButton(
            onPressed: () async {
              Injector.of(context).authRepo.signOut();
              Navigator.pushReplacementNamed(context, Routes.signIn);
            },
            child: const Text('Press here to Sign Out')),
      ),
    );
  }
}
