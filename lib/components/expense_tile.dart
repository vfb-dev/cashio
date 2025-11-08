import 'package:cashio/models/expense.dart';
import 'package:cashio/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class ExpenseTile extends StatelessWidget {
  final bool isTopTile;
  final bool isBottomTile;
  final Expense expense;

  const ExpenseTile({
    super.key,
    this.isTopTile = false,
    this.isBottomTile = false,
    required this.expense,
  });

  String formatNumber(double value) {
    if (value.abs() >= 1_000_000) {
      // Compact format for millions, billions, trillions
      return NumberFormat.compactCurrency(
        locale: 'en_US',
        symbol: '',
        decimalDigits: 1,
      ).format(value);
    } else {
      // Normal currency for smaller amounts
      return NumberFormat.currency(
        locale: 'en_US',
        symbol: '',
        decimalDigits: 2,
      ).format(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 64,
      decoration: BoxDecoration(
        color: AppColors.bgTwo,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Colors.black, // solid shadow color (no opacity)
            offset: Offset(4, 4), // sharp offset, no blur
          ),
        ],
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const HSLColor.fromAHSL(1.0, 0, 0, 0.95).toColor(),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2), // inner element depth
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  IconData(
                    expense.categoryIconCode,
                    fontFamily: 'MaterialIcons',
                  ),
                  size: 24,
                  color: AppColors.text,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                expense.name,
                style: GoogleFonts.figtree(
                  color: AppColors.text,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  height: 0,
                ),
              ),
              Text(
                DateFormat('dd/MM/yyyy').format(expense.date),
                style: GoogleFonts.figtree(
                  color: AppColors.mutedText,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            formatNumber(expense.value),
            style: GoogleFonts.figtree(
              color: AppColors.text,
              fontSize: 16,
              fontWeight: FontWeight.w900,
              height: 0,
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }
}
