import 'package:cashio/models/cashio_database.dart';
import 'package:cashio/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

class TopBar extends StatefulWidget {
  const TopBar({super.key});

  @override
  State<TopBar> createState() => _TopBarState();
}

class _TopBarState extends State<TopBar> {
  String? selectedValue;
  List<String> monthYearItems = [];
  CashioDatabase? db;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      db = Provider.of<CashioDatabase>(context, listen: false);
      db?.addListener(_loadMonthYearItems);
      _loadMonthYearItems();
    });
  }

  @override
  void dispose() {
    db?.removeListener(_loadMonthYearItems);
    super.dispose();
  }

  Future<void> _loadMonthYearItems() async {
    if (db == null) return;

    final items = await db!.getUniqueDateOptions();
    final now = DateTime.now();
    final currentMonthYear = '${now.month}/${now.year}';
    final currentYear = '${now.year}';

    final updatedItems = {...items, currentMonthYear, currentYear}.toList();

    updatedItems.sort((a, b) {
      final aParts = a.split('/');
      final bParts = b.split('/');

      final aYear = int.parse(aParts.last);
      final bYear = int.parse(bParts.last);

      if (bYear != aYear) return bYear.compareTo(aYear);

      if (aParts.length == 2 && bParts.length == 2) {
        final aMonth = int.parse(aParts.first);
        final bMonth = int.parse(bParts.first);
        return bMonth.compareTo(aMonth);
      }

      return aParts.length == 2 ? -1 : 1;
    });

    if (mounted) {
      setState(() {
        monthYearItems = updatedItems;
        if (selectedValue == null || !monthYearItems.contains(selectedValue)) {
          selectedValue = updatedItems.isNotEmpty
              ? updatedItems.first
              : currentMonthYear;
        }
      });
    }
  }

  void _openDateSelector() async {
    if (monthYearItems.isEmpty) return;

    final controller = TextEditingController();
    List<String> filteredItems = List.from(monthYearItems);

    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (context) {
        final media = MediaQuery.of(context);
        final keyboardHeight = media.viewInsets.bottom;
        final topPadding = media.padding.top;
        final maxHeight = media.size.height - topPadding - keyboardHeight - 24;

        return SafeArea(
          top: true,
          bottom: true,
          child: Padding(
            padding: EdgeInsets.only(bottom: keyboardHeight),
            child: DraggableScrollableSheet(
              initialChildSize: 0.6,
              minChildSize: 0.4,
              maxChildSize: 0.85,
              expand: false,
              builder: (context, scrollController) {
                return Container(
                  constraints: BoxConstraints(maxHeight: maxHeight),
                  decoration: const BoxDecoration(
                    color: AppColors.bgOne,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 8),

                      // 🔍 Search Field
                      TextField(
                        controller: controller,
                        decoration: InputDecoration(
                          hintText: tr('topBar.searchMonthYear'),
                          hintStyle: const TextStyle(color: Colors.black38),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Colors.black54,
                          ),
                          filled: true,
                          fillColor: Colors.black12,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        onChanged: (query) {
                          filteredItems = monthYearItems.where((item) {
                            final lowerQuery = query.toLowerCase();
                            final lowerItem = item.toLowerCase();
                            final parts = item.split('/');
                            final yearPart = parts.last.toLowerCase();

                            // Match full string or just the year
                            return lowerItem.contains(lowerQuery) ||
                                yearPart.contains(lowerQuery);
                          }).toList();
                          (context as Element).markNeedsBuild(); // refresh
                        },
                      ),
                      const SizedBox(height: 16),

                      // 🗓 List of Months/Years
                      Expanded(
                        child: ListView.builder(
                          controller: scrollController,
                          itemCount: filteredItems.length,
                          itemBuilder: (_, index) {
                            final item = filteredItems[index];
                            final isSelected = item == selectedValue;
                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.black.withOpacity(0.05)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                title: Text(
                                  item,
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 16,
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                  ),
                                ),
                                trailing: isSelected
                                    ? const Icon(
                                        Icons.check,
                                        color: Colors.black,
                                      )
                                    : null,
                                onTap: () => Navigator.pop(context, item),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 🧭 Cancel Button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              tr('modals.actions.cancel'),
                              style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );

    if (result != null && result != selectedValue) {
      setState(() => selectedValue = result);
      db?.currentMonthYear = result;
      await db?.fetchExpensesByDateOption(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        height: 48,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Builder(
              builder: (context) => IconButton(
                iconSize: 28,
                padding: const EdgeInsets.all(8),
                splashRadius: 24,
                onPressed: () => Scaffold.of(context).openDrawer(),
                icon: SvgPicture.asset(
                  'lib/assets/images/Menu.svg',
                  height: 18,
                  width: 18,
                  colorFilter: const ColorFilter.mode(
                    AppColors.text,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: _openDateSelector,
              child: Container(
                decoration: BoxDecoration(color: Colors.transparent),
                child: Row(
                  children: [
                    const Icon(Icons.arrow_drop_down, color: AppColors.text),
                    Text(
                      selectedValue ?? tr('topBar.selectDate'),
                      style: const TextStyle(
                        color: AppColors.text,
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
