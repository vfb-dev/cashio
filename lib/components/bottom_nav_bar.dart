import 'package:cashio/themes/app_colors.dart';
import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const BottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      decoration: const BoxDecoration(
        color: AppColors.bgOne,
        border: Border(top: BorderSide(color: AppColors.border, width: 0.7)),
      ),
      child: Row(
        children: [
          _buildNavItem(Icons.home, 0),
          _buildDivider(),
          _buildNavItem(Icons.donut_large_outlined, 1),
          _buildDivider(),
          _buildNavItem(Icons.bar_chart_rounded, 2),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    final isSelected = selectedIndex == index;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque, // makes the whole area tappable
        onTap: () => onItemTapped(index),
        child: Center(
          child: Icon(
            icon,
            size: 32,
            color: isSelected ? AppColors.text : AppColors.mutedText, // gray
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      color: AppColors.border, // divider
    );
  }
}
