import 'package:cashio/components/balance_tile.dart';
import 'package:cashio/components/expense_modal.dart';
import 'package:cashio/components/expense_tile.dart';
import 'package:cashio/components/hint_overlay.dart';
import 'package:cashio/models/cashio_database.dart';
import 'package:cashio/themes/app_colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _showHint = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final db = Provider.of<CashioDatabase>(context, listen: false);
      final prefs = await SharedPreferences.getInstance();

      final savedPeriod = prefs.getString('selectedMonthYear');
      final now = DateTime.now();
      final defaultPeriod = '${now.month}/${now.year}';
      final periodToLoad = savedPeriod ?? defaultPeriod;

      await db.fetchExpensesByDateOption(periodToLoad);
    });
  }

  void _toggleHint() {
    setState(() {
      _showHint = !_showHint;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgOne,
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 32, right: 32),
                child: BalanceTile(),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  const SizedBox(width: 32),
                  Text(
                    'home.expenses'.tr(),
                    style: GoogleFonts.figtree(
                      color: AppColors.text,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      height: 0,
                    ),
                  ),
                  const SizedBox(width: 5),
                  GestureDetector(
                    onTap: _toggleHint,
                    child: const Icon(
                      Icons.help_outline,
                      color: AppColors.mutedText,
                      size: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Consumer<CashioDatabase>(
                  builder: (context, db, child) {
                    final expenses = db.currentExpenses;

                    if (expenses.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.list_alt,
                              size: 80,
                              color: AppColors.mutedText,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'home.noExpenses'.tr(), // <-- localized
                              style: GoogleFonts.figtree(
                                fontSize: 21,
                                fontWeight: FontWeight.w600,
                                color: AppColors.mutedText,
                              ),
                            ),
                            const SizedBox(height: 128),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.only(bottom: 16),
                      itemCount: expenses.length,
                      itemBuilder: (context, index) {
                        final expense = expenses[index];
                        return Padding(
                          padding: const EdgeInsets.only(
                            left: 32,
                            right: 32,
                            bottom: 16,
                          ),
                          child: Slidable(
                            key: ValueKey(expense.id),
                            endActionPane: ActionPane(
                              motion: const DrawerMotion(),
                              extentRatio: 0.4,
                              children: [
                                SlidableAction(
                                  onPressed: (_) {
                                    showExpenseBottomModal(
                                      context,
                                      existingExpense: expense,
                                    );
                                  },
                                  backgroundColor: AppColors.bgOne,
                                  foregroundColor: AppColors.text,
                                  icon: Icons.edit,
                                  label: 'actions.edit'.tr(), // <-- localized
                                ),
                                SlidableAction(
                                  onPressed: (_) async {
                                    final db = Provider.of<CashioDatabase>(
                                      context,
                                      listen: false,
                                    );
                                    await db.deleteExpense(expense.id);
                                  },
                                  backgroundColor: AppColors.bgOne,
                                  foregroundColor: AppColors.secondary,
                                  icon: Icons.delete,
                                  label: 'actions.delete'.tr(), // <-- localized
                                ),
                              ],
                            ),
                            child: ExpenseTile(
                              expense: expense,
                              isTopTile: index == 0,
                              isBottomTile: index == expenses.length - 1,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),

          // Floating button
          Positioned(
            bottom: 40,
            right: 40,
            child: GestureDetector(
              onTap: () => showExpenseBottomModal(context),
              child: Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: AppColors.text,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.add,
                    color: const HSLColor.fromAHSL(1.0, 0, 0, 0.95).toColor(),
                    size: 40,
                  ),
                ),
              ),
            ),
          ),

          // ✅ Hint overlay
          if (_showHint) HintOverlay(onDismiss: _toggleHint),
        ],
      ),
    );
  }
}
