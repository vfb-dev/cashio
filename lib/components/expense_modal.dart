import 'package:cashio/components/inputs/category_grid.dart';
import 'package:cashio/components/inputs/date_field.dart';
import 'package:cashio/models/expense.dart';
import 'package:cashio/models/cashio_database.dart';
import 'package:cashio/themes/app_colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExpenseBottomModal extends StatefulWidget {
  final Expense? existingExpense;
  const ExpenseBottomModal({super.key, this.existingExpense});

  @override
  State<ExpenseBottomModal> createState() => _ExpenseBottomModalState();
}

class _ExpenseBottomModalState extends State<ExpenseBottomModal> {
  final _nameController = TextEditingController();
  final _valueController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedCategory;
  int? _selectedCategoryIcon;

  bool get isEditing => widget.existingExpense != null;

  @override
  void initState() {
    super.initState();
    final exp = widget.existingExpense;
    if (exp != null) {
      _nameController.text = exp.name;
      _valueController.text = exp.value.toStringAsFixed(2);
      _selectedDate = exp.date;
      _selectedCategory = exp.categoryName;
      _selectedCategoryIcon = exp.categoryIconCode;
    }
  }

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<CashioDatabase>(context, listen: false);

    return SafeArea(
      bottom: true,
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.bgOne,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),

              // 📝 Name Field
              TextField(
                controller: _nameController,
                maxLength: 20,
                style: GoogleFonts.figtree(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  hintText: 'modals.expense.nameHint'.tr(),
                  hintStyle: GoogleFonts.figtree(color: Colors.black38),
                  prefixIcon: const Icon(Icons.edit, color: Colors.black),
                  filled: true,
                  fillColor: Colors.black12,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 💵 Value + Date Fields
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _valueController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d{0,2}'),
                        ),
                      ],
                      style: GoogleFonts.figtree(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: InputDecoration(
                        hintText: 'modals.expense.valueHint'.tr(),
                        hintStyle: GoogleFonts.figtree(color: Colors.black38),
                        prefixIcon: const Icon(
                          Icons.attach_money,
                          color: Colors.black,
                        ),
                        filled: true,
                        fillColor: Colors.black12,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DateField(
                      selectedDate: _selectedDate,
                      onDateSelected: (date) =>
                          setState(() => _selectedDate = date),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 🗂 Category Grid
              SizedBox(
                height: 200,
                child: CategoryGrid(
                  selectedCategory: _selectedCategory,
                  onCategorySelected: (label, iconCode) {
                    setState(() {
                      _selectedCategory = label;
                      _selectedCategoryIcon = iconCode;
                    });
                  },
                ),
              ),
              const SizedBox(height: 28),

              // 🧭 Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'modals.actions.cancel'.tr(),
                      style: GoogleFonts.figtree(
                        color: Colors.black54,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: Icon(
                      isEditing ? Icons.save : Icons.add,
                      color: Colors.white,
                    ),
                    label: Text(
                      isEditing
                          ? 'modals.actions.saveChanges'.tr()
                          : 'modals.actions.add'.tr(),
                      style: GoogleFonts.figtree(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    onPressed: () async {
                      if (_nameController.text.isEmpty ||
                          _valueController.text.isEmpty ||
                          _selectedDate == null ||
                          _selectedCategory == null ||
                          _selectedCategoryIcon == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("modals.expense.fillAll".tr()),
                          ),
                        );
                        return;
                      }

                      final value = double.tryParse(_valueController.text) ?? 0;
                      if (value > 1_000_000_000_000) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "modals.expense.expenseValueLimit".tr(),
                            ),
                          ),
                        );
                        return;
                      }

                      final prefs = await SharedPreferences.getInstance();
                      final selectedPeriod = prefs.getString(
                        'selectedMonthYear',
                      );

                      if (isEditing) {
                        final updatedExpense = widget.existingExpense!
                          ..name = _nameController.text
                          ..value = value
                          ..date = _selectedDate!
                          ..categoryName = _selectedCategory!
                          ..categoryIconCode = _selectedCategoryIcon!;
                        await db.updateExpense(updatedExpense);
                      } else {
                        await db.addExpense(
                          name: _nameController.text,
                          value: value,
                          date: _selectedDate!,
                          categoryName: _selectedCategory!,
                          categoryIconCode: _selectedCategoryIcon!,
                        );
                      }

                      if (selectedPeriod != null) {
                        await db.fetchExpensesByDateOption(selectedPeriod);
                      }

                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void showExpenseBottomModal(BuildContext context, {Expense? existingExpense}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withOpacity(0.3),
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        bottom: true, // ✅ ensures safe area from bottom
        child: ExpenseBottomModal(existingExpense: existingExpense),
      ),
    ),
  );
}
