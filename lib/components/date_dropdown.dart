import 'package:cashio/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DateDropdown extends StatelessWidget {
  final List<String> items;
  final String? value;
  final ValueChanged<String?> onChanged;

  const DateDropdown({
    super.key,
    required this.items,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // 🔹 Fallback if selected value no longer exists
    final currentValue = items.contains(value)
        ? value
        : (items.isNotEmpty ? items.first : null);

    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: currentValue,
        isExpanded: false,
        icon: const SizedBox.shrink(),
        dropdownColor: AppColors.bgOne,
        style: GoogleFonts.figtree(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.text,
        ),
        items: items
            .map(
              (item) =>
                  DropdownMenuItem<String>(value: item, child: Text(item)),
            )
            .toList(),
        onChanged: onChanged,
        selectedItemBuilder: (context) {
          return items.map((item) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.arrow_drop_down, color: AppColors.text),
                Text(item),
              ],
            );
          }).toList();
        },
      ),
    );
  }
}
