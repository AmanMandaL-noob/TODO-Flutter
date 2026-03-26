// lib/widgets/status_chip.dart

import 'package:flutter/material.dart';
import '../models/task.dart';
import '../utils/app_theme.dart';

class StatusChip extends StatelessWidget {
  final TaskStatus status;
  final bool small;

  const StatusChip({super.key, required this.status, this.small = false});

  @override
  Widget build(BuildContext context) {
    final color = status.value.statusColor;
    final bg = status.value.statusBgColor;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 8 : 10,
        vertical: small ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: small ? 5 : 6,
            height: small ? 5 : 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: small ? 4 : 5),
          Text(
            status.label,
            style: TextStyle(
              color: color,
              fontSize: small ? 10 : 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
