import 'package:cashio/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cashio/models/cashio_database.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

class BalanceAlertModal extends StatelessWidget {
  final double currentBalance;
  final String monthYear;

  const BalanceAlertModal({
    super.key,
    required this.currentBalance,
    required this.monthYear,
  });

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();
    final db = Provider.of<CashioDatabase>(context, listen: false);

    return Dialog(
      backgroundColor: AppColors.bgOne,
      insetPadding: const EdgeInsets.all(32),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // 💰 Input Field
            TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              style: GoogleFonts.figtree(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                hintText: 'modals.balance.hint'.tr(),
                hintStyle: GoogleFonts.figtree(color: Colors.black38),
                prefixIcon: const Icon(
                  Icons.account_balance_wallet,
                  color: Colors.black,
                ),
                filled: true,
                fillColor: Colors.black12,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.text),
                ),
              ),
            ),

            const SizedBox(height: 28),

            // 🧭 Buttons
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
                  icon: const Icon(Icons.save, color: Colors.white),
                  label: Text(
                    'modals.actions.save'.tr(),
                    style: GoogleFonts.figtree(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  onPressed: () async {
                    final value = double.tryParse(controller.text);
                    if (value == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('modals.balance.invalidNumber'.tr()),
                        ),
                      );
                      return;
                    }

                    if (value > 1_000_000_000_000) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'modals.balance.expenseValueLimit'.tr(),
                          ),
                        ),
                      );
                      return;
                    }

                    await db.setBalanceForMonthYear(monthYear, value);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
