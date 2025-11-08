import 'package:isar/isar.dart';

part 'balance.g.dart';

@Collection()
class Balance {
  Id id = Isar.autoIncrement;
  late double value;
  late DateTime date;
}
