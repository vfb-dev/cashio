import 'package:cashio/components/balance_alert_modal.dart';
import 'package:cashio/models/balance.dart';
import 'package:cashio/models/cashio_database.dart';
import 'package:cashio/themes/app_colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BalanceTile extends StatefulWidget {
  const BalanceTile({super.key});

  @override
  State<BalanceTile> createState() => _BalanceTileState();
}

class _BalanceTileState extends State<BalanceTile> {
  bool _isHidden = false;

  @override
  void initState() {
    super.initState();
    _loadHiddenState();
  }

  Future<void> _loadHiddenState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isHidden = prefs.getBool('balanceHidden') ?? false;
    });
  }

  Future<void> _saveHiddenState(bool hidden) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('balanceHidden', hidden);
  }

  void _toggleHidden() {
    setState(() {
      _isHidden = !_isHidden;
      _saveHiddenState(_isHidden); // persist change
    });
  }

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

  String hiddenValue() => '••••';

  @override
  Widget build(BuildContext context) {
    return Consumer<CashioDatabase>(
      builder: (context, db, child) {
        final dateOption =
            db.currentMonthYear ??
            '${DateTime.now().month}/${DateTime.now().year}';
        final isMonthYear = dateOption.contains('/');

        final future = isMonthYear
            ? db
                  .getBalanceForMonthYear(dateOption)
                  .then((b) => [b].whereType<Balance>().toList())
            : db.getBalancesForYear(dateOption);

        return FutureBuilder<List<Balance>>(
          future: future,
          builder: (context, snapshot) {
            final balances = snapshot.data ?? [];
            final totalBalance = balances.fold<double>(
              0.0,
              (sum, b) => sum + b.value,
            );
            final totalExpenses = db.currentExpenses.fold<double>(
              0.0,
              (sum, e) => sum + e.value,
            );
            final remaining = totalBalance - totalExpenses;

            final formattedBalance = formatNumber(totalBalance);
            final formattedRemaining = formatNumber(remaining);
            final formattedExpenses = formatNumber(totalExpenses);

            return Container(
              width: double.infinity,
              height: 128,
              decoration: BoxDecoration(
                color: AppColors.bgTwo,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black, width: 3),
                boxShadow: const [
                  BoxShadow(color: Colors.black, offset: Offset(6, 6)),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 24, top: 16, right: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // HEADER ROW WITH TITLE + EYE ICON IN TOP-RIGHT
                    Row(
                      children: [
                        Text(
                          isMonthYear
                              ? 'home.balance'.tr()
                              : 'home.balanceYear'.tr(),
                          style: GoogleFonts.figtree(
                            color: AppColors.mutedText,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Spacer(),
                        GestureDetector(
                          onTap: _toggleHidden, // <-- use toggle
                          child: Icon(
                            _isHidden ? Icons.visibility_off : Icons.visibility,
                            color: AppColors.mutedText,
                          ),
                        ),
                      ],
                    ),
                    // BALANCE VALUE
                    GestureDetector(
                      onTap: isMonthYear
                          ? () {
                              showDialog(
                                context: context,
                                builder: (context) => BalanceAlertModal(
                                  currentBalance: totalBalance,
                                  monthYear: dateOption,
                                ),
                              );
                            }
                          : null,
                      child: Text(
                        _isHidden ? hiddenValue() : formattedBalance,
                        style: GoogleFonts.figtree(
                          color: AppColors.text,
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.26,
                          height: 1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // REMAINING / EXPENSES SECTION
                    Row(
                      children: [
                        const Icon(Icons.arrow_circle_up),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 100,
                          child: Text(
                            _isHidden ? hiddenValue() : formattedRemaining,
                            style: GoogleFonts.figtree(
                              color: AppColors.primary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        const Icon(Icons.arrow_circle_down),
                        const SizedBox(width: 8),
                        Text(
                          _isHidden ? hiddenValue() : formattedExpenses,
                          style: GoogleFonts.figtree(
                            color: AppColors.secondary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
