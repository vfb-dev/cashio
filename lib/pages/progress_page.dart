import 'package:cashio/models/balance.dart';
import 'package:cashio/models/cashio_database.dart';
import 'package:cashio/models/expense.dart';
import 'package:cashio/themes/app_colors.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:isar/isar.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  List<double> monthlyNetValues = List.filled(12, 0.0);
  double meanPercent = 0.0;
  late CashioDatabase db;

  // ✅ number formatting function reused from BalanceTile
  String formatNumber(double value) {
    if (value.abs() >= 1_000_000) {
      return NumberFormat.compactCurrency(
        locale: 'en_US',
        symbol: '',
        decimalDigits: 1,
      ).format(value);
    } else {
      return NumberFormat.currency(
        locale: 'en_US',
        symbol: '',
        decimalDigits: 2,
      ).format(value);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    db = Provider.of<CashioDatabase>(context);
    db.addListener(_loadChartDataFromDropdown);
    _loadChartDataFromDropdown();
  }

  @override
  void dispose() {
    db.removeListener(_loadChartDataFromDropdown);
    super.dispose();
  }

  Future<void> _loadChartDataFromDropdown() async {
    final selectedOption = db.currentMonthYear;

    if (selectedOption == null || selectedOption.isEmpty) {
      final fallbackYear = DateTime.now().year.toString();
      await _loadChartData(fallbackYear);
      return;
    }

    final yearStr = selectedOption.contains('/')
        ? selectedOption.split('/').last
        : selectedOption;

    await _loadChartData(yearStr);
  }

  Future<void> _loadChartData(String yearStr) async {
    final year = int.tryParse(yearStr);
    if (year == null) return;

    final balances = await CashioDatabase.isar.balances
        .filter()
        .dateBetween(DateTime(year, 1, 1), DateTime(year + 1, 1, 0))
        .findAll();

    final expenses = await CashioDatabase.isar.expenses
        .filter()
        .dateBetween(DateTime(year, 1, 1), DateTime(year + 1, 1, 0))
        .findAll();

    final Map<int, double> balanceByMonth = {};
    final Map<int, double> expenseByMonth = {};

    for (var b in balances) {
      final m = b.date.month;
      balanceByMonth[m] = (balanceByMonth[m] ?? 0) + b.value;
    }

    for (var e in expenses) {
      final m = e.date.month;
      expenseByMonth[m] = (expenseByMonth[m] ?? 0) + e.value;
    }

    final List<double> net = List.generate(12, (i) {
      final month = i + 1;
      final balance = balanceByMonth[month] ?? 0;
      final expense = expenseByMonth[month] ?? 0;
      return balance - expense;
    });

    final List<double> monthlySavingsPercent = List.generate(12, (i) {
      final month = i + 1;
      final income = balanceByMonth[month] ?? 0;
      final netValue = net[i];
      if (income == 0) return 0;
      return (netValue / income) * 100;
    });

    final nonZeroMonths = monthlySavingsPercent
        .where((v) => v != 0)
        .toList(growable: false);
    final meanSavings = nonZeroMonths.isEmpty
        ? 0
        : nonZeroMonths.reduce((a, b) => a + b) / nonZeroMonths.length;

    if (mounted) {
      setState(() {
        monthlyNetValues = net;
        meanPercent = meanSavings.toDouble();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final months = ['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'];
    final hasData = monthlyNetValues.any((v) => v != 0);

    if (!hasData) {
      return Scaffold(
        backgroundColor: AppColors.bgOne,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.bar_chart, size: 80, color: AppColors.mutedText),
              const SizedBox(height: 8),
              Text(
                'progressPage.noData'.tr(),
                style: GoogleFonts.figtree(
                  fontSize: 21,
                  fontWeight: FontWeight.w600,
                  color: AppColors.mutedText,
                ),
              ),
              const SizedBox(height: 128),
            ],
          ),
        ),
      );
    }

    double totalBalance = monthlyNetValues.fold(0, (a, b) => a + b);

    final minY = monthlyNetValues.reduce((a, b) => a < b ? a : b);
    final maxY = monthlyNetValues.reduce((a, b) => a > b ? a : b);

    return Scaffold(
      backgroundColor: AppColors.bgOne,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'progressPage.performanceTitle'.tr(),
              style: GoogleFonts.figtree(
                color: AppColors.text,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                height: 0,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 300,
              child: BarChart(
                BarChartData(
                  baselineY: 0,
                  minY: minY,
                  maxY: maxY,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) {
                      if (value == 0) {
                        return FlLine(color: Colors.grey, strokeWidth: 2);
                      }
                      return FlLine(color: Colors.transparent);
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < months.length) {
                            return Text(
                              months[index],
                              style: TextStyle(
                                color: AppColors.text.withOpacity(0.7),
                                fontSize: 12,
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ),
                  barGroups: List.generate(12, (i) {
                    final net = monthlyNetValues[i];
                    final isPositive = net >= 0;
                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          fromY: 0,
                          toY: net,
                          color: isPositive
                              ? AppColors.text
                              : AppColors.secondary,
                          borderRadius: BorderRadius.circular(4),
                          width: 14,
                        ),
                      ],
                    );
                  }),
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (touchedSpot) => AppColors.bgTwo,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final value = rod.toY;
                        final isPositive = value >= 0;
                        return BarTooltipItem(
                          formatNumber(value), // ✅ formatted number
                          TextStyle(
                            color: isPositive
                                ? AppColors.text
                                : AppColors.secondary,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'progressPage.moreInfoTitle'.tr(),
              style: GoogleFonts.figtree(
                color: AppColors.text,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                height: 0,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 2,
                itemBuilder: (context, index) {
                  String title;
                  String value;
                  double width;
                  Color valueColor = AppColors.text;

                  if (index == 0) {
                    title = 'progressPage.meanSavings'.tr();
                    value = '${meanPercent.toStringAsFixed(1)}%';
                    valueColor = meanPercent >= 0
                        ? AppColors.text
                        : AppColors.secondary;
                    width = 256;
                  } else {
                    title = 'progressPage.accumulated'.tr();
                    value = formatNumber(totalBalance); // ✅ formatted
                    width = 256;
                  }

                  return Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      width: width,
                      height: 100,
                      margin: const EdgeInsets.only(right: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.bgTwo,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.black, width: 3),
                        boxShadow: const [
                          BoxShadow(color: Colors.black, offset: Offset(6, 6)),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            title,
                            style: GoogleFonts.figtree(
                              color: AppColors.mutedText,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            value,
                            style: GoogleFonts.figtree(
                              color: valueColor,
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
