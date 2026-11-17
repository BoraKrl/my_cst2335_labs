// The magic conditional import syntax
import 'connection.dart'
if (dart.library.js_util) 'web.dart'
if (dart.library.io) 'native.dart';

import 'package:drift/drift.dart';

part 'AppDatabase.g.dart';   //<< This tells flutter where to put the generated code later.

@DriftDatabase(
  include: {'contact.drift'},   // << This is your .drift file you wrote
)
class AppDatabase extends _$AppDatabase {

  AppDatabase() : super(openConnection());


  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration{
    return MigrationStrategy(
      onUpgrade: (migrator, from, to) async {
        await migrator.createAll();
      },
      beforeOpen: (details) async {

      }
    );
  }
}
