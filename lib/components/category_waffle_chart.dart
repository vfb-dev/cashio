import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cashio/themes/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:cashio/models/cashio_database.dart';
import 'package:easy_localization/easy_localization.dart';

class CategoryWaffleChart extends StatefulWidget {
  const CategoryWaffleChart({super.key});

  static const int gridSize = 10; // 10x10 = 100 squares
  static const int maxCategories = 6;

  @override
  State<CategoryWaffleChart> createState() => _CategoryWaffleChartState();
}

class _CategoryWaffleChartState extends State<CategoryWaffleChart> {
  String? selectedCategory;
  double? selectedValue;

  static const _colors = [
    Color(0xFF4E79A7),
    Color(0xFFF28E2B),
    Color(0xFFE15759),
    Color(0xFF76B7B2),
    Color(0xFF59A14F),
    Color(0xFFEDC948),
  ];

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<CashioDatabase>(context);
    final expenses = db.currentExpenses;

    if (expenses.isEmpty) return _emptyState();

    final categoryBlocks = _prepareCategoryBlocks(expenses);
    final cells = _generateCells(categoryBlocks);

    return Column(
      children: [
        _buildGrid(cells),
        _buildInfoDisplay(),
        _buildLegend(categoryBlocks),
      ],
    );
  }

  Widget _emptyState() => Padding(
    padding: const EdgeInsets.all(32.0),
    child: Text(
      'home.noExpenses'.tr(),
      style: GoogleFonts.figtree(color: AppColors.mutedText, fontSize: 16),
      textAlign: TextAlign.center,
    ),
  );

  List<_CategoryBlock> _prepareCategoryBlocks(List expenses) {
    final Map<String, double> sums = {};
    for (var e in expenses) {
      sums[e.categoryName] = (sums[e.categoryName] ?? 0) + e.value;
    }

    final total = sums.values.fold(0.0, (a, b) => a + b);
    if (total == 0) return [];

    final sortedCategories = sums.keys.toList()
      ..sort((a, b) => sums[b]!.compareTo(sums[a]!));

    final limited = sortedCategories
        .take(CategoryWaffleChart.maxCategories)
        .toList();
    final othersSum = sortedCategories
        .skip(CategoryWaffleChart.maxCategories)
        .fold<double>(0, (sum, c) => sum + sums[c]!);

    final blocks = <_CategoryBlock>[];
    for (int i = 0; i < limited.length; i++) {
      final category = limited[i];
      final value = sums[category]!;
      final isLast = i == limited.length - 1;

      if (isLast && othersSum > 0) {
        final otherBlocks = ((othersSum / total) * 100).round();
        blocks.add(
          _CategoryBlock("categories.other".tr(), otherBlocks, othersSum),
        );
      } else {
        final blockCount = ((value / total) * 100).round();
        blocks.add(_CategoryBlock(category, blockCount, value));
      }
    }

    // Adjust to ensure total 100 blocks
    final currentSum = blocks.fold<int>(0, (sum, b) => sum + b.blocks);
    if (currentSum != 100 && blocks.isNotEmpty) {
      final diff = 100 - currentSum;
      final last = blocks.last;
      blocks[blocks.length - 1] = _CategoryBlock(
        last.category,
        last.blocks + diff,
        last.value,
      );
    }

    return blocks;
  }

  List<_CellData> _generateCells(List<_CategoryBlock> blocks) {
    final cells = <_CellData>[];

    for (int i = 0; i < blocks.length; i++) {
      final color = _colors[i % _colors.length];
      cells.addAll(
        List.generate(
          blocks[i].blocks,
          (_) => _CellData(
            categoryName: blocks[i].category,
            value: blocks[i].value,
            color: color,
          ),
        ),
      );
    }

    // Ensure exactly 100 cells
    if (cells.length > 100) cells.removeRange(100, cells.length);
    if (cells.length < 100) {
      cells.addAll(
        List.generate(
          100 - cells.length,
          (_) => _CellData(
            categoryName: "None",
            value: 0,
            color: AppColors.mutedText.withOpacity(0.2),
          ),
        ),
      );
    }

    return cells;
  }

  Widget _buildGrid(List<_CellData> cells) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
    child: AspectRatio(
      aspectRatio: 1,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: CategoryWaffleChart.gridSize,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
        ),
        itemCount: 100,
        itemBuilder: (context, index) {
          final cell = cells[index];
          return GestureDetector(
            onTap: () {
              if (cell.value > 0) {
                setState(() {
                  selectedCategory = cell.categoryName;
                  selectedValue = cell.value;
                });
              }
            },
            child: Container(
              decoration: BoxDecoration(
                color: cell.color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        },
      ),
    ),
  );

  Widget _buildInfoDisplay() => Padding(
    padding: const EdgeInsets.symmetric(vertical: 16),
    child: Text(
      selectedCategory != null && selectedValue != null
          ? '$selectedCategory: \$${selectedValue!.toStringAsFixed(2)}'
          : 'stats.hint'.tr(),
      textAlign: TextAlign.center,
      style: GoogleFonts.figtree(
        fontSize: 16,
        fontWeight: selectedCategory != null
            ? FontWeight.bold
            : FontWeight.normal,
        color: selectedCategory != null ? AppColors.text : AppColors.mutedText,
        fontStyle: selectedCategory == null
            ? FontStyle.italic
            : FontStyle.normal,
      ),
    ),
  );

  Widget _buildLegend(List<_CategoryBlock> blocks) => Wrap(
    alignment: WrapAlignment.center,
    spacing: 16,
    runSpacing: 8,
    children: List.generate(blocks.length, (i) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            margin: const EdgeInsets.only(right: 6),
            decoration: BoxDecoration(
              color: _colors[i % _colors.length],
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          Text(
            '${blocks[i].category} ${blocks[i].blocks}%',
            style: GoogleFonts.figtree(fontSize: 14, color: AppColors.text),
          ),
        ],
      );
    }),
  );
}

class _CategoryBlock {
  final String category;
  final int blocks;
  final double value;
  const _CategoryBlock(this.category, this.blocks, this.value);
}

class _CellData {
  final String categoryName;
  final double value;
  final Color color;
  const _CellData({
    required this.categoryName,
    required this.value,
    required this.color,
  });
}
