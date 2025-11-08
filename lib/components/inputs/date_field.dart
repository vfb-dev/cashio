import 'package:cashio/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A reusable date input field
class DateField extends StatelessWidget {
  final DateTime? selectedDate;
  final ValueChanged<DateTime?> onDateSelected;

  const DateField({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      style: GoogleFonts.figtree(
        color: const HSLColor.fromAHSL(1.0, 234, 0.17, 0.41).toColor(),
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
      readOnly: true,
      controller: TextEditingController(
        text: selectedDate == null
            ? ""
            : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
      ),
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        hintText: 'Date',
        prefixIcon: const Icon(Icons.calendar_today),
        filled: true, // 👈 enable background
        fillColor: AppColors.bgOne,
      ),
      onTap: () async {
        final picked = await pickDate(context, selectedDate);
        if (picked != null) {
          onDateSelected(picked);
        }
      },
    );
  }
}

/// Helper function for showing the date picker
Future<DateTime?> pickDate(BuildContext context, DateTime? currentDate) {
  return showDatePicker(
    context: context,
    initialDate: currentDate ?? DateTime.now(),
    firstDate: DateTime(2000),
    lastDate: DateTime(2100),
  );
}
