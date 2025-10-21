import 'package:flutter/material.dart';
import 'package:app/app/app.dart';
import 'package:app/core/services/persistence_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PersistenceService().init();
  runApp(const MyApp());
}