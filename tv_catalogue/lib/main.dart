import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'app/my_app.dart';
import 'providers.dart';

void main() {
  runApp(
    MultiProvider(
      providers: providers,
      child: const MyApp(),
    ),
  );
}
