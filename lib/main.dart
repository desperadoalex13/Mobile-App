import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/firebase/firebase_options.dart';
import 'core/logging/app_log_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await AppLogService.instance.initialize();

  FlutterError.onError = (FlutterErrorDetails details) {
    AppLogService.instance.error(
      'Flutter error: ${details.exception}',
      stackTrace: details.stack,
    );
    FlutterError.presentError(details);
  };

  runApp(const ProviderScope(child: App()));
}
