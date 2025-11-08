import 'package:cashio/themes/app_colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CategoryTile extends StatelessWidget {
  final String categoryName;
  final int categoryIconCode;
  final double totalValue;
  final double percentage; // 0..1

  const CategoryTile({
    super.key,
    required this.categoryName,
    required this.categoryIconCode,
    required this.totalValue,
    required this.percentage,
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
      height: 64, // same as ExpenseTile
      decoration: BoxDecoration(
        color: AppColors.bgTwo,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black, width: 2),
        boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(4, 4))],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            // Category Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const HSLColor.fromAHSL(1.0, 0, 0, 0.95).toColor(),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  IconData(categoryIconCode, fontFamily: 'MaterialIcons'),
                  size: 24,
                  color: AppColors.text,
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Name + value + full-width bar
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + Value in the same row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        categoryName,
                        style: GoogleFonts.figtree(
                          color: AppColors.text,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          height: 0,
                        ),
                      ),
                      Text(
                        formatNumber(totalValue),
                        style: GoogleFonts.figtree(
                          color: AppColors.text,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          height: 0,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // Full-width horizontal bar
                  Stack(
                    children: [
                      Container(
                        height: 8,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.mutedText.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: percentage.clamp(0.0, 1.0),
                        child: Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppColors.text,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
