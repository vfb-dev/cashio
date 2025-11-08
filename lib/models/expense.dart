import 'package:isar/isar.dart';

part 'expense.g.dart';

@Collection()
class Expense {
  Id id = Isar.autoIncrement;
  late String name;
  late double value;
  late DateTime date;
  late String categoryName;
  late int categoryIconCode;
}
