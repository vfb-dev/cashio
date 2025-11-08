import 'package:cashio/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';

class HeroPage extends StatelessWidget {
  const HeroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgOne,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 280),

            // LOGO
            Center(
              child: SvgPicture.asset(
                'lib/assets/images/cash.svg',
                width: 100,
                height: 100,
                colorFilter: const ColorFilter.mode(
                  AppColors.text,
                  BlendMode.srcIn,
                ),
              ),
            ),
            const Spacer(),

            // TITLE
            SizedBox(
              child: Text(
                'hero.title'.tr(), // <- localized
                textAlign: TextAlign.left,
                style: GoogleFonts.figtree(
                  color: AppColors.text,
                  fontSize: 31,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.31,
                  height: 1,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // BODY TEXT
            SizedBox(
              width: 340,
              child: Text(
                'hero.subTitle'.tr(),
                textAlign: TextAlign.left,
                style: GoogleFonts.figtree(
                  color: AppColors.mutedText,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0,
                  height: 1.5,
                ),
              ),
            ),

            const SizedBox(height: 34),

            // BUTTON
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/maestropage');
              },
              child: Container(
                width: double.infinity,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.text,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    'hero.continue'.tr(), // <- localized
                    style: GoogleFonts.figtree(
                      color: AppColors.bgTwo,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.24,
                      height: 1,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 88),
          ],
        ),
      ),
    );
  }
}
