import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  AppTextStyles._();

  // Headings
  static TextStyle get h1 =>
      GoogleFonts.dmSans(fontSize: 32, fontWeight: FontWeight.w700);
  static TextStyle get h2 =>
      GoogleFonts.dmSans(fontSize: 28, fontWeight: FontWeight.w700);
  static TextStyle get h3 =>
      GoogleFonts.dmSans(fontSize: 24, fontWeight: FontWeight.w700);
  static TextStyle get h4 =>
      GoogleFonts.dmSans(fontSize: 20, fontWeight: FontWeight.w600);
  static TextStyle get h5 =>
      GoogleFonts.dmSans(fontSize: 18, fontWeight: FontWeight.w600);
  static TextStyle get h6 =>
      GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w600);

  // Body
  static TextStyle get bodyLg =>
      GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w400);
  static TextStyle get bodyMd =>
      GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w400);
  static TextStyle get bodySm =>
      GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w400);

  // Label
  static TextStyle get labelLg =>
      GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w500);
  static TextStyle get labelMd =>
      GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w500);
  static TextStyle get labelSm =>
      GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.w500);

  // Special use
  static TextStyle get buttonText =>
      GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600);
  static TextStyle get navItem =>
      GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w500);
  static TextStyle get caption =>
      GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w400);
}