import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomToggleButtom extends StatefulWidget {
  final double width;
  final double heigth;

  const CustomToggleButtom({
    super.key,
    required this.width,
    required this.heigth,
  });

  @override
  State<CustomToggleButtom> createState() => _CustomToggleButtomState();
}

class _CustomToggleButtomState extends State<CustomToggleButtom> {
  List<bool> isSelected = [true, false];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.heigth,
      decoration: BoxDecoration(
        color: const HSLColor.fromAHSL(1.0, 234, 0.17, 0.60).toColor(),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const HSLColor.fromAHSL(1.0, 234, 0.17, 0.21).toColor(),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  'Expenses',
                  style: GoogleFonts.figtree(
                    color: const HSLColor.fromAHSL(1.0, 0, 0, 0.95).toColor(),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    height: 0,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
              child: Center(
                child: Text(
                  'Ranking',
                  style: GoogleFonts.figtree(
                    color: const HSLColor.fromAHSL(1.0, 0, 0, 0.95).toColor(),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    height: 0,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
