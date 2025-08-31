// This file is run before any tests
import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  // Initialize FFI for SQLite
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  
  // Initialize integration test bindings
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  // Run the tests
  await testMain();
}
