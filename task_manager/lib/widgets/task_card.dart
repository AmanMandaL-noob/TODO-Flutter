// lib/widgets/task_card.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../utils/app_theme.dart';
import 'highlight_text.dart';
import 'status_chip.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final String searchQuery;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const TaskCard({
    super.key,
    required this.task,
    required this.searchQuery,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final isBlocked = provider.isTaskEffectivelyBlocked(task);
    final blockerTask = task.blockedById != null
        ? provider.getTaskById(task.blockedById!)
        : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Dismissible(
        key: Key('task_${task.id}'),
        direction: DismissDirection.endToStart,
        confirmDismiss: (_) async {
          return await _confirmDelete(context);
        },
        onDismissed: (_) => onDelete(),
        background: _buildDismissBackground(),
        child: GestureDetector(
          onTap: isBlocked ? null : onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isBlocked ? AppColors.blockedBg : AppColors.cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isBlocked
                    ? const Color(0xFFE2E8F0)
                    : task.isOverdue
                        ? AppColors.overdue.withOpacity(0.3)
                        : const Color(0xFFE2E8F0),
                width: 1.5,
              ),
              boxShadow: isBlocked
                  ? []
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Stack(
              children: [
                // Done strikethrough overlay
                if (task.status == TaskStatus.done)
                  Positioned(
                    left: 16,
                    top: 0,
                    bottom: 0,
                    right: 0,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        height: 1.5,
                        color: AppColors.done.withOpacity(0.3),
                        margin: const EdgeInsets.only(right: 80),
                      ),
                    ),
                  ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top row: status + options
                      Row(
                        children: [
                          StatusChip(status: task.status, small: true),
                          const Spacer(),
                          if (task.isOverdue && task.status != TaskStatus.done)
                            _buildOverdueBadge(),
                          const SizedBox(width: 8),
                          _buildOptionsMenu(context),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Title
                      HighlightText(
                        text: task.title,
                        query: searchQuery,
                        baseStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.3,
                          color: isBlocked
                              ? AppColors.textDisabled
                              : task.status == TaskStatus.done
                                  ? AppColors.textSecondary
                                  : AppColors.textPrimary,
                          decoration: task.status == TaskStatus.done
                              ? TextDecoration.lineThrough
                              : null,
                          decorationColor: AppColors.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      // Description
                      if (task.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          task.description,
                          style: TextStyle(
                            fontSize: 13,
                            color: isBlocked
                                ? AppColors.textDisabled
                                : AppColors.textSecondary,
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],

                      const SizedBox(height: 12),
                      const Divider(height: 1),
                      const SizedBox(height: 10),

                      // Bottom row: due date + blocked badge
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 13,
                            color: task.isOverdue && task.status != TaskStatus.done
                                ? AppColors.overdue
                                : AppColors.textDisabled,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            DateFormat('MMM d, yyyy').format(task.dueDate),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: task.isOverdue &&
                                      task.status != TaskStatus.done
                                  ? AppColors.overdue
                                  : AppColors.textSecondary,
                            ),
                          ),
                          const Spacer(),
                          if (isBlocked) _buildBlockedBadge(blockerTask),
                        ],
                      ),
                    ],
                  ),
                ),

                // Blocked dim overlay
                if (isBlocked)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDismissBackground() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.overdue,
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.delete_outline_rounded, color: Colors.white, size: 24),
          SizedBox(height: 4),
          Text(
            'Delete',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverdueBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.overdueLight,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: AppColors.overdue.withOpacity(0.3)),
      ),
      child: const Text(
        'Overdue',
        style: TextStyle(
          color: AppColors.overdue,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildBlockedBadge(Task? blocker) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFCBD5E1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.lock_outline_rounded,
              size: 10, color: AppColors.blocked),
          const SizedBox(width: 4),
          Text(
            blocker != null
                ? 'Blocked by: ${blocker.title.length > 12 ? '${blocker.title.substring(0, 12)}…' : blocker.title}'
                : 'Blocked',
            style: const TextStyle(
              color: AppColors.blocked,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsMenu(BuildContext context) {
    return SizedBox(
      width: 28,
      height: 28,
      child: PopupMenuButton<String>(
        padding: EdgeInsets.zero,
        icon: const Icon(Icons.more_horiz_rounded,
            size: 18, color: AppColors.textSecondary),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 8,
        itemBuilder: (_) => [
          PopupMenuItem(
            value: 'edit',
            child: _menuItem(Icons.edit_outlined, 'Edit', AppColors.textPrimary),
          ),
          PopupMenuItem(
            value: 'delete',
            child: _menuItem(
                Icons.delete_outline_rounded, 'Delete', AppColors.overdue),
          ),
        ],
        onSelected: (val) {
          if (val == 'edit') onTap();
          if (val == 'delete') onDelete();
        },
      ),
    );
  }

  Widget _menuItem(IconData icon, String label, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 10),
        Text(label,
            style: TextStyle(
                color: color, fontSize: 14, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('Delete Task',
                style: TextStyle(fontWeight: FontWeight.w700)),
            content: Text(
              'Are you sure you want to delete "${task.title}"? This action cannot be undone.',
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 14, height: 1.5),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.overdue),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;
  }
}
