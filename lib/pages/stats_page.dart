import 'package:cashio/components/category_waffle_chart.dart';
import 'package:cashio/components/category_tile.dart';
import 'package:cashio/themes/app_colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cashio/models/cashio_database.dart';
import 'package:cashio/models/expense.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  bool showWaffle = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgOne,
      body: SafeArea(
        child: Consumer<CashioDatabase>(
          builder: (context, db, child) {
            final expenses = db.currentExpenses;

            // ✅ Empty state
            if (expenses.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.donut_large_outlined,
                      size: 80,
                      color: AppColors.mutedText,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'home.noExpenses'.tr(),
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

            // Group expenses by category
            final Map<String, List<Expense>> grouped = {};
            for (var expense in expenses) {
              grouped.putIfAbsent(expense.categoryName, () => []).add(expense);
            }

            // Sort by total value descending
            final sortedEntries = grouped.entries.toList()
              ..sort((a, b) {
                final aTotal = a.value.fold<double>(
                  0,
                  (sum, e) => sum + e.value,
                );
                final bTotal = b.value.fold<double>(
                  0,
                  (sum, e) => sum + e.value,
                );
                return bTotal.compareTo(aTotal);
              });

            // ✅ Calculate total of all categories
            final totalValueAllCategories = sortedEntries
                .map(
                  (entry) =>
                      entry.value.fold<double>(0, (sum, e) => sum + e.value),
                )
                .fold<double>(0, (sum, e) => sum + e);

            final List<Widget> tiles = sortedEntries.map((entry) {
              final categoryName = entry.key;
              final expenses = entry.value;
              final categoryValue = expenses.fold<double>(
                0,
                (sum, e) => sum + e.value,
              );
              final categoryIconCode = expenses.first.categoryIconCode;

              // ✅ Percentage based on total, not the biggest category
              final percent = totalValueAllCategories > 0
                  ? (categoryValue / totalValueAllCategories) * 100
                  : 0;

              return Padding(
                padding: const EdgeInsets.only(bottom: 16, left: 32, right: 32),
                child: Slidable(
                  key: ValueKey(categoryName),
                  endActionPane: ActionPane(
                    motion: const DrawerMotion(),
                    extentRatio: 0.25,
                    children: [
                      CustomSlidableAction(
                        onPressed: (_) {},
                        backgroundColor: AppColors.bgOne,
                        foregroundColor: AppColors.text,
                        child: Center(
                          child: Text(
                            '${percent.toStringAsFixed(1)}%',
                            style: GoogleFonts.figtree(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.text,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  child: CategoryTile(
                    categoryName: categoryName,
                    categoryIconCode: categoryIconCode,
                    totalValue: categoryValue,
                    percentage: totalValueAllCategories > 0
                        ? categoryValue / totalValueAllCategories
                        : 0,
                  ),
                ),
              );
            }).toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔘 Title + Toggle
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.bgTwo,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            _buildToggleButton(
                              label: "Percent",
                              selected: showWaffle,
                              onTap: () => setState(() => showWaffle = true),
                            ),
                            _buildToggleButton(
                              label: "Ranking",
                              selected: !showWaffle,
                              onTap: () => setState(() => showWaffle = false),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // 🔄 Animated switch between views
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) =>
                        FadeTransition(opacity: animation, child: child),
                    child: showWaffle
                        ? const Center(child: CategoryWaffleChart())
                        : ListView(
                            key: const ValueKey('ranking'),
                            children: [...tiles, const SizedBox(height: 24)],
                          ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildToggleButton({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.text : AppColors.bgTwo,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: GoogleFonts.figtree(
            color: selected ? AppColors.bgTwo : AppColors.text,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
