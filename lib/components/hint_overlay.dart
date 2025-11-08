import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HintOverlay extends StatefulWidget {
  final VoidCallback onDismiss;

  const HintOverlay({super.key, required this.onDismiss});

  @override
  State<HintOverlay> createState() => _HintOverlayState();
}

class _HintOverlayState extends State<HintOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _arrowController;
  late final Animation<Offset> _arrowAnimation;

  @override
  void initState() {
    super.initState();

    _arrowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _arrowAnimation =
        Tween<Offset>(
          begin: const Offset(0, 0),
          end: const Offset(-0.2, 0),
        ).animate(
          CurvedAnimation(parent: _arrowController, curve: Curves.easeInOut),
        );
  }

  @override
  void dispose() {
    _arrowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onDismiss,
      child: Container(
        color: Colors.black.withOpacity(0.85),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: SizedBox(
                  width: 300,
                  child: Text(
                    'home.hint'.tr(),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.figtree(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SlideTransition(
                position: _arrowAnimation,
                child: const Icon(
                  Icons.arrow_left,
                  color: Colors.white,
                  size: 48,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
