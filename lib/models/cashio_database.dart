import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:cashio/models/expense.dart';
import 'package:cashio/models/balance.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';

class CashioDatabase extends ChangeNotifier {
  static late Isar isar;

  String? currentMonthYear;
  final List<Expense> currentExpenses = [];

  static Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open([ExpenseSchema, BalanceSchema], directory: dir.path);
  }

  // ✅ FIX: keep selected month/year even if all expenses are deleted
  Future<void> _refreshAndNotify() async {
    if (currentMonthYear != null) {
      await fetchExpensesByDateOption(currentMonthYear!);

      // Preserve selection if month/year disappears due to no data
      final availableDates = await getUniqueDateOptions();
      if (!availableDates.contains(currentMonthYear)) {
        notifyListeners();
      } else {
        notifyListeners();
      }
    } else {
      await fetchExpenses();
      notifyListeners();
    }
  }

  Future<void> addExpense({
    required String name,
    required double value,
    required DateTime date,
    required String categoryName,
    required int categoryIconCode,
  }) async {
    final newExpense = Expense()
      ..name = name
      ..value = value
      ..date = date
      ..categoryName = categoryName
      ..categoryIconCode = categoryIconCode;

    await isar.writeTxn(() => isar.expenses.put(newExpense));
    await _refreshAndNotify();
  }

  Future<void> fetchExpenses() async {
    final fetchedExpenses = await isar.expenses.where().findAll();
    currentExpenses
      ..clear()
      ..addAll(fetchedExpenses);
    notifyListeners();
  }

  Future<void> updateExpense(Expense expense) async {
    await isar.writeTxn(() => isar.expenses.put(expense));
    await _refreshAndNotify();
  }

  Future<void> deleteExpense(int id) async {
    // 1️⃣ Find the expense before deleting
    final expense = await isar.expenses.get(id);
    if (expense == null) return;

    // 2️⃣ Delete the expense
    await isar.writeTxn(() async {
      await isar.expenses.delete(id);
    });

    // ✅ Refresh view and preserve date selection
    await _refreshAndNotify();
  }

  Future<List<String>> getUniqueDateOptions() async {
    final expenses = await isar.expenses.where().findAll();
    final balances = await isar.balances.where().findAll();

    final monthYearSet = <String>{};
    final yearSet = <String>{};

    // 🧾 Add from expenses
    for (var expense in expenses) {
      final month = expense.date.month;
      final year = expense.date.year;
      monthYearSet.add('$month/$year');
      yearSet.add('$year');
    }

    // 💰 Add from balances
    for (var balance in balances) {
      final month = balance.date.month;
      final year = balance.date.year;
      monthYearSet.add('$month/$year');
      yearSet.add('$year');
    }

    // 🧩 Preserve the currently selected month/year even if empty
    if (currentMonthYear != null) {
      monthYearSet.add(currentMonthYear!);
    }

    // Combine both sets
    final combined = {...monthYearSet, ...yearSet}.toList();

    // Sort newest first
    combined.sort((a, b) {
      final aParts = a.split('/');
      final bParts = b.split('/');

      final aYear = int.parse(aParts.last);
      final bYear = int.parse(bParts.last);

      if (bYear != aYear) return bYear.compareTo(aYear);

      if (aParts.length == 2 && bParts.length == 2) {
        final aMonth = int.parse(aParts.first);
        final bMonth = int.parse(bParts.first);
        return bMonth.compareTo(aMonth);
      }

      return aParts.length == 2 ? -1 : 1;
    });

    return combined;
  }

  Future<void> fetchExpensesByDateOption(String dateOption) async {
    final parts = dateOption.split('/');

    int? month;
    int? year;

    if (parts.length == 2) {
      month = int.tryParse(parts[0]);
      year = int.tryParse(parts[1]);
    } else if (parts.length == 1) {
      year = int.tryParse(parts[0]);
    }

    if (year == null) return;

    currentMonthYear = dateOption;

    final startDate = DateTime(year, month ?? 1, 1);
    final endDate = month != null
        ? DateTime(year, month + 1, 0, 23, 59, 59)
        : DateTime(year + 1, 1, 0, 23, 59, 59);

    final fetchedExpenses = await isar.expenses
        .filter()
        .dateBetween(startDate, endDate)
        .findAll();

    fetchedExpenses.sort((a, b) => b.date.compareTo(a.date));

    currentExpenses
      ..clear()
      ..addAll(fetchedExpenses);

    notifyListeners();
  }

  // ========================= BALANCE METHODS =========================

  Future<Balance?> getBalanceForMonthYear(String monthYear) async {
    final parts = monthYear.split('/');
    if (parts.length != 2) return null;
    final month = int.tryParse(parts[0]);
    final year = int.tryParse(parts[1]);
    if (month == null || year == null) return null;

    final balances = await isar.balances
        .filter()
        .dateBetween(
          DateTime(year, month, 1),
          DateTime(year, month + 1, 0, 23, 59, 59),
        )
        .findAll();

    return balances.isNotEmpty ? balances.first : null;
  }

  Future<void> setBalanceForMonthYear(String monthYear, double value) async {
    final parts = monthYear.split('/');
    if (parts.length != 2) return;
    final month = int.tryParse(parts[0]);
    final year = int.tryParse(parts[1]);
    if (month == null || year == null) return;

    Balance? existing = await getBalanceForMonthYear(monthYear);

    if (existing != null) {
      existing.value = value;
      await isar.writeTxn(() => isar.balances.put(existing));
    } else {
      final newBalance = Balance()
        ..value = value
        ..date = DateTime(year, month, 1);
      await isar.writeTxn(() => isar.balances.put(newBalance));
    }

    notifyListeners();
  }

  Future<List<Balance>> getAllBalances() async {
    return await isar.balances.where().findAll();
  }

  Future<List<Balance>> getBalancesForYear(String yearStr) async {
    final year = int.tryParse(yearStr);
    if (year == null) return [];

    final balances = await isar.balances
        .filter()
        .dateBetween(DateTime(year, 1, 1), DateTime(year + 1, 1, 0, 23, 59, 59))
        .findAll();

    return balances;
  }

  // ========================= EXPORT / IMPORT =========================

  Future<void> exportData(BuildContext context) async {
    try {
      final expenses = await isar.expenses.where().findAll();
      final balances = await isar.balances.where().findAll();

      final data = {
        'expenses': expenses
            .map(
              (e) => {
                'id': e.id,
                'name': e.name,
                'value': e.value,
                'date': e.date.toIso8601String(),
                'categoryName': e.categoryName,
                'categoryIconCode': e.categoryIconCode,
              },
            )
            .toList(),
        'balances': balances
            .map(
              (b) => {
                'id': b.id,
                'value': b.value,
                'date': b.date.toIso8601String(),
              },
            )
            .toList(),
      };

      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/cashio_backup.json');
      await file.writeAsString(jsonEncode(data));

      final result = await Share.shareXFiles([
        XFile(file.path),
      ], text: 'Coin Hound Backup');

      if (result.status == ShareResultStatus.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Export completed successfully')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('❌ Export failed: $e')));
    }
  }

  Future<void> importData(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.isEmpty) return;

      final file = File(result.files.single.path!);
      final content = await file.readAsString();
      final jsonData = jsonDecode(content);

      final expensesData = (jsonData['expenses'] as List?) ?? [];
      final balancesData = (jsonData['balances'] as List?) ?? [];

      await isar.writeTxn(() async {
        await isar.expenses.clear();
        await isar.balances.clear();

        for (var e in expensesData) {
          final expense = Expense()
            ..name = e['name']
            ..value = (e['value'] as num).toDouble()
            ..date = DateTime.parse(e['date'])
            ..categoryName = e['categoryName']
            ..categoryIconCode = e['categoryIconCode'];
          await isar.expenses.put(expense);
        }

        for (var b in balancesData) {
          final balance = Balance()
            ..value = (b['value'] as num).toDouble()
            ..date = DateTime.parse(b['date']);
          await isar.balances.put(balance);
        }
      });

      await fetchExpenses();
      notifyListeners();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Import completed successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('❌ Import failed: $e')));
    }
  }
}
