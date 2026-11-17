// We use a conditional export to expose the right connection factory depending
// on the platform.
// connection.dart
import 'package:drift/drift.dart';

// This function will be replaced dynamically at runtime depending on the platform
QueryExecutor openConnection() => throw UnsupportedError('Platform not supported');
