import 'package:flutter/material.dart';
import '../models/task.dart';
import '../theme/app_theme.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VibePalette palette;
  final Function(TaskStatus) onStatusChange;
  final VoidCallback? onAssignToToday;
  final VoidCallback? onDemoteToBacklog;
  final VoidCallback? onPostponeOneDay;
  final VoidCallback? onPostponeToDate;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final int? dragIndex;

  const TaskCard({
    super.key,
    required this.task,
    required this.palette,
    required this.onStatusChange,
    this.onAssignToToday,
    this.onDemoteToBacklog,
    this.onPostponeOneDay,
    this.onPostponeToDate,
    this.onDelete,
    this.onEdit,
    this.dragIndex,
  });

  @override
  Widget build(BuildContext context) {
    Color cardBg = palette.bgElevated;
    Color cardBorder = palette.borderSubtle;
    double cardOpacity = 1.0;
    TextStyle titleStyle = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: palette.textMain,
    );

    if (task.status == TaskStatus.done) {
      cardBg = const Color(0x1010B981);
      cardBorder = const Color(0x4D10B981);
      cardOpacity = 0.65;
      titleStyle = titleStyle.copyWith(
        decoration: TextDecoration.lineThrough,
        color: palette.textMuted,
      );
    } else if (task.status == TaskStatus.postponed) {
      cardBg = const Color(0x14F59E0B);
      cardBorder = const Color(0x66F59E0B);
    } else if (task.status == TaskStatus.canceled) {
      cardBg = const Color(0x10EF4444);
      cardBorder = const Color(0x4DEF4444);
      cardOpacity = 0.55;
      titleStyle = titleStyle.copyWith(
        decoration: TextDecoration.lineThrough,
        color: const Color(0xFFEF4444),
      );
    }

    return Opacity(
      opacity: cardOpacity,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cardBg,
          border: Border.all(color: cardBorder),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Linked Media Goal Badge if attached
            if (task.linkedMediaId != null) ...[
              Container(
                margin: const EdgeInsets.only(left: 26, bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: palette.accentPrimary.withValues(alpha: 0.15),
                  border: Border.all(color: palette.borderSubtle),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '🎯 Media Goal: ${task.mediaTitle ?? 'Linked Media'}',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: palette.accentPrimary,
                      ),
                    ),
                    if (task.mediaUnitsToAdvance != null) ...[
                      const SizedBox(width: 4),
                      Text(
                        '• +${task.mediaUnitsToAdvance!.toInt()}',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: palette.textMain,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],

            // Top Row: Drag Handle + Title + Options Menu
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2, right: 8),
                  child: dragIndex != null
                      ? ReorderableDragStartListener(
                          index: dragIndex!,
                          child: MouseRegion(
                            cursor: SystemMouseCursors.grab,
                            child: Icon(
                              Icons.drag_indicator,
                              size: 18,
                              color: palette.textDim,
                            ),
                          ),
                        )
                      : Icon(
                          Icons.drag_indicator,
                          size: 18,
                          color: palette.textDim,
                        ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: onEdit,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(task.title, style: titleStyle),
                        if (task.notes.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            task.notes,
                            style: TextStyle(
                              fontSize: 12,
                              color: palette.textMuted,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                if (onDelete != null)
                  IconButton(
                    icon: Icon(Icons.close, size: 16, color: palette.textDim),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: onDelete,
                  ),
              ],
            ),

            const SizedBox(height: 8),
            Divider(color: const Color(0x0FFFFFFF), height: 1),
            const SizedBox(height: 8),

            // Bottom Actions Row: 3-State Controls + Context
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 3-State Action Buttons
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: palette.bgSurface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Done Button
                      _buildStateButton(
                        label: 'Done',
                        isActive: task.status == TaskStatus.done,
                        activeBg: const Color(0xFF10B981),
                        activeFg: Colors.black,
                        targetStatus: TaskStatus.done,
                      ),
                      const SizedBox(width: 3),

                      // Postpone to Tomorrow Button (Daily items)
                      if (task.category == TaskCategory.daily) ...[
                        InkWell(
                          onTap: () {
                            if (onPostponeOneDay != null) {
                              onPostponeOneDay!();
                            } else if (task.status == TaskStatus.postponed) {
                              onStatusChange(TaskStatus.pending);
                            } else {
                              onStatusChange(TaskStatus.postponed);
                            }
                          },
                          onLongPress: onPostponeToDate,
                          borderRadius: BorderRadius.circular(6),
                          child: Tooltip(
                            message: 'Tap: Postpone +1 Day | Hold: Pick Future Date',
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: task.status == TaskStatus.postponed
                                    ? const Color(0xFFF59E0B)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Tomorrow',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: task.status == TaskStatus.postponed
                                      ? Colors.black
                                      : palette.textMuted,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 3),
                      ],

                      // Cancel Button
                      _buildStateButton(
                        label: 'Cancel',
                        isActive: task.status == TaskStatus.canceled,
                        activeBg: const Color(0xFFEF4444),
                        activeFg: Colors.white,
                        targetStatus: TaskStatus.canceled,
                      ),
                    ],
                  ),
                ),

                // Right side: Assign to Today or Demote to Backlog or Badge
                if (task.category == TaskCategory.general && onAssignToToday != null)
                  InkWell(
                    onTap: onAssignToToday,
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: palette.borderSubtle),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.bolt,
                            size: 13,
                            color: palette.accentPrimary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Assign Today',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: palette.accentPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (task.category == TaskCategory.daily && onDemoteToBacklog != null)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: onDemoteToBacklog,
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: palette.borderSubtle),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.move_to_inbox,
                                size: 12,
                                color: palette.textMuted,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                'To Backlog',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: palette.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        task.linkedMediaId != null
                            ? '+${task.mediaUnitsToAdvance?.toInt() ?? 0} on check'
                            : (task.status == TaskStatus.postponed
                                ? 'Postponed (${task.postponedCount}x)'
                                : 'Due Today'),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: task.linkedMediaId != null ? FontWeight.bold : FontWeight.normal,
                          color: task.linkedMediaId != null ? palette.accentPrimary : palette.textDim,
                        ),
                      ),
                    ],
                  )
                else
                  Text(
                    task.linkedMediaId != null
                        ? '+${task.mediaUnitsToAdvance?.toInt() ?? 0} on check'
                        : (task.status == TaskStatus.postponed
                            ? 'Postponed (${task.postponedCount}x)'
                            : 'Due Today'),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: task.linkedMediaId != null ? FontWeight.bold : FontWeight.normal,
                      color: task.linkedMediaId != null ? palette.accentPrimary : palette.textDim,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStateButton({
    required String label,
    required bool isActive,
    required Color activeBg,
    required Color activeFg,
    required TaskStatus targetStatus,
  }) {
    return InkWell(
      onTap: () {
        if (isActive) {
          onStatusChange(TaskStatus.pending); // Toggle off back to pending
        } else {
          onStatusChange(targetStatus);
        }
      },
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isActive ? activeBg : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isActive ? activeFg : palette.textMuted,
          ),
        ),
      ),
    );
  }
}
