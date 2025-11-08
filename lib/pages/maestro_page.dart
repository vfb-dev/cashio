import 'package:cashio/components/bottom_nav_bar.dart';
import 'package:cashio/components/top_bar.dart';
import 'package:cashio/models/cashio_database.dart';
import 'package:cashio/pages/home_page.dart';
import 'package:cashio/pages/progress_page.dart';
import 'package:cashio/pages/stats_page.dart';
import 'package:cashio/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart'; // <— Added

class MaestroPage extends StatefulWidget {
  const MaestroPage({super.key});

  @override
  State<MaestroPage> createState() => _MaestroPageState();
}

class _MaestroPageState extends State<MaestroPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const StatsPage(),
    const ProgressPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgOne,
      drawer: Drawer(
        backgroundColor: AppColors.bgTwo,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // LOGO
                Center(
                  child: SvgPicture.asset(
                    'lib/assets/images/cash.svg',
                    width: 64,
                    height: 64,
                    colorFilter: const ColorFilter.mode(
                      AppColors.text,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                const SizedBox(height: 64),

                const Divider(color: AppColors.mutedText, thickness: 1),

                // MENU ITEMS
                ListTile(
                  leading: const Icon(
                    Icons.file_download,
                    color: AppColors.text,
                  ),
                  title: Text(
                    'drawer.exportData'.tr(),
                    style: GoogleFonts.figtree(
                      color: AppColors.text,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () async {
                    final db = Provider.of<CashioDatabase>(
                      context,
                      listen: false,
                    );
                    Navigator.pop(context);
                    await db.exportData(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.file_upload, color: AppColors.text),
                  title: Text(
                    'drawer.importData'.tr(),
                    style: GoogleFonts.figtree(
                      color: AppColors.text,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () async {
                    final db = Provider.of<CashioDatabase>(
                      context,
                      listen: false,
                    );
                    Navigator.pop(context);
                    await db.importData(context);
                  },
                ),
              ],
            ),
          ),
        ),
      ),

      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: TopBar(),
            ),
            Expanded(
              child: IndexedStack(index: _selectedIndex, children: _pages),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: BottomNavBar(
          selectedIndex: _selectedIndex,
          onItemTapped: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
      ),
    );
  }
}
