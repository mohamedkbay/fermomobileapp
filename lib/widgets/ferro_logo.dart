import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/ferro_colors.dart';

class FerroLogo extends StatelessWidget {
  final double size;
  final Color color;

  const FerroLogo({
    super.key,
    this.size = 40,
    this.color = FerroColors.amber,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      'فِرّو',
      style: GoogleFonts.cairo(
        fontSize: size,
        fontWeight: FontWeight.w900,
        color: color,
        letterSpacing: -1,
      ),
    );
  }
}
