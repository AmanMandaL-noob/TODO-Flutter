// lib/widgets/highlight_text.dart

import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class HighlightText extends StatelessWidget {
  final String text;
  final String query;
  final TextStyle? baseStyle;
  final TextStyle? highlightStyle;
  final int? maxLines;
  final TextOverflow? overflow;

  const HighlightText({
    super.key,
    required this.text,
    required this.query,
    this.baseStyle,
    this.highlightStyle,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    if (query.isEmpty) {
      return Text(
        text,
        style: baseStyle,
        maxLines: maxLines,
        overflow: overflow,
      );
    }

    final spans = <TextSpan>[];
    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();

    int start = 0;
    int idx;

    while ((idx = lowerText.indexOf(lowerQuery, start)) != -1) {
      if (idx > start) {
        spans.add(TextSpan(
          text: text.substring(start, idx),
          style: baseStyle,
        ));
      }
      spans.add(TextSpan(
        text: text.substring(idx, idx + query.length),
        style: (highlightStyle ??
            TextStyle(
              backgroundColor: AppColors.primary.withOpacity(0.18),
              color: AppColors.primaryDark,
              fontWeight: FontWeight.w700,
            )),
      ));
      start = idx + query.length;
    }

    if (start < text.length) {
      spans.add(TextSpan(
        text: text.substring(start),
        style: baseStyle,
      ));
    }

    return RichText(
      text: TextSpan(children: spans),
      maxLines: maxLines,
      overflow: overflow ?? TextOverflow.clip,
    );
  }
}
