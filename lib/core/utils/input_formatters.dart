import 'package:flutter/services.dart';

/// Blocks all whitespace, including pasted spaces. For email, password, OTP
/// and phone fields where a space is never valid.
final List<TextInputFormatter> noWhitespace = [
  FilteringTextInputFormatter.deny(RegExp(r'\s')),
];
