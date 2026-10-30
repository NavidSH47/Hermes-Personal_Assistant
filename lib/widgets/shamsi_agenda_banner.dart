import 'package:flutter/material.dart';
import 'package:shamsi_date/shamsi_date.dart';
import '../models/shamsi_event.dart';
import '../theme/app_theme.dart';
import '../services/dual_calendar_service.dart';
import '../services/date_navigation_service.dart';

class ShamsiAgendaBanner extends StatefulWidget {
  final List<ShamsiEvent> events;
  final VibePalette palette;
  final Function(ShamsiEvent) onToggleCheckpoint;
  final Function(ShamsiEvent) onAddEvent;
  final Jalali? selectedDate;
  final Function(Jalali)? onDateChanged;

  const ShamsiAgendaBanner({
    super.key,
    required this.events,
    required this.palette,
    required this.onToggleCheckpoint,
    required this.onAddEvent,
    this.selectedDate,
    this.onDateChanged,
  });

  @override
  State<ShamsiAgendaBanner> createState() => _ShamsiAgendaBannerState();
}

class _ShamsiAgendaBannerState extends State<ShamsiAgendaBanner> {
  bool _isCalendarExpanded = false;
  late Jalali _internalSelectedDate;

  Jalali get _selectedDate => widget.selectedDate ?? _internalSelectedDate;

  @override
  void initState() {
    super.initState();
    _internalSelectedDate = widget.selectedDate ?? Jalali.now();
  }

  void _changeDate(Jalali newDate) {
    setState(() {
      _internalSelectedDate = newDate;
    });
    widget.onDateChanged?.call(newDate);
  }

  static const List<String> _shamsiMonthNames = [
    'فروردین',
    'اردیبهشت',
    'خرداد',
    'تیر',
    'مرداد',
    'شهریور',
    'مهر',
    'آبان',
    'آذر',
    'دی',
    'بهمن',
    'اسفند',
  ];

  static const List<String> _persianWeekdays = [
    'شنبه',
    'یکشنبه',
    'دوشنبه',
    'سه‌شنبه',
    'چهارشنبه',
    'پنج‌شنبه',
    'جمعه',
  ];

  String _toPersianDigits(int number) {
    const farsiDigits = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
    return number
        .toString()
        .split('')
        .map((ch) {
          final idx = int.tryParse(ch);
          return idx != null ? farsiDigits[idx] : ch;
        })
        .join();
  }

  String _getWeekdayName(int weekDay) {
    // Jalali weekDay: 1 = Saturday (شنبه) to 7 = Friday (جمعه)
    if (weekDay >= 1 && weekDay <= 7) {
      return _persianWeekdays[weekDay - 1];
    }
    return '';
  }

  Widget _buildQuickNavButton({
    required String label,
    required VoidCallback onTap,
    bool isHighlighted = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isHighlighted
              ? widget.palette.accentPrimary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w600,
            color: isHighlighted ? Colors.black : widget.palette.textMain,
          ),
        ),
      ),
    );
  }

  List<ShamsiEvent> _eventsForSelectedDay() {
    return widget.events.where((e) {
      return e.isEnabled &&
          e.jalaliMonth == _selectedDate.month &&
          e.jalaliDay == _selectedDate.day;
    }).toList();
  }

  bool _dayHasEvent(int month, int day) {
    return widget.events.any(
      (e) => e.isEnabled && e.jalaliMonth == month && e.jalaliDay == day,
    );
  }

  void _showAddEventDialog() {
    final titleController = TextEditingController();
    final noteController = TextEditingController();
    EventCategory selectedCategory = EventCategory.birthday;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            return AlertDialog(
              backgroundColor: widget.palette.bgElevated,
              title: Text(
                'Add Event / Reminder',
                style: TextStyle(
                  color: widget.palette.textMain,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Date: ${_selectedDate.day} ${_shamsiMonthNames[_selectedDate.month - 1]}',
                      style: TextStyle(
                        color: widget.palette.accentPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: titleController,
                      style: TextStyle(color: widget.palette.textMain),
                      decoration: InputDecoration(
                        labelText: 'Title (e.g. Birthday, Exam, Milestone)',
                        labelStyle: TextStyle(color: widget.palette.textMuted),
                        filled: true,
                        fillColor: widget.palette.bgSurface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              BorderSide(color: widget.palette.borderSubtle),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: noteController,
                      style: TextStyle(color: widget.palette.textMain),
                      decoration: InputDecoration(
                        labelText: 'Notes (optional)',
                        labelStyle: TextStyle(color: widget.palette.textMuted),
                        filled: true,
                        fillColor: widget.palette.bgSurface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              BorderSide(color: widget.palette.borderSubtle),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<EventCategory>(
                      initialValue: selectedCategory,
                      dropdownColor: widget.palette.bgElevated,
                      style: TextStyle(color: widget.palette.textMain),
                      decoration: InputDecoration(
                        labelText: 'Category',
                        labelStyle: TextStyle(color: widget.palette.textMuted),
                        filled: true,
                        fillColor: widget.palette.bgSurface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              BorderSide(color: widget.palette.borderSubtle),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: EventCategory.birthday,
                          child: Text('🎂 Birthday'),
                        ),
                        DropdownMenuItem(
                          value: EventCategory.customDate,
                          child: Text('🎯 Milestone / Exam'),
                        ),
                        DropdownMenuItem(
                          value: EventCategory.holiday,
                          child: Text('🏛️ Important Date'),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() => selectedCategory = val);
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogCtx),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: widget.palette.textMuted),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.palette.accentPrimary,
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () {
                    final title = titleController.text.trim();
                    if (title.isNotEmpty) {
                      final newEvent = ShamsiEvent(
                        id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
                        title: title,
                        jalaliMonth: _selectedDate.month,
                        jalaliDay: _selectedDate.day,
                        isCustom: true,
                        category: selectedCategory,
                        note: noteController.text.trim().isEmpty
                            ? null
                            : noteController.text.trim(),
                      );
                      widget.onAddEvent(newEvent);
                      Navigator.pop(dialogCtx);
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedDayEvents = _eventsForSelectedDay();
    final monthName = _shamsiMonthNames[_selectedDate.month - 1];
    final weekdayName = _getWeekdayName(_selectedDate.weekDay);
    final monthLength = _selectedDate.monthLength;

    return Container(
      decoration: BoxDecoration(
        color: widget.palette.bgSurface,
        border: Border.all(color: widget.palette.borderSubtle),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Shamsi Date Badge
              Row(
                children: [
                  Text(
                    _toPersianDigits(_selectedDate.day),
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: widget.palette.textMain,
                      height: 1,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$monthName ${_toPersianDigits(_selectedDate.year)}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: widget.palette.accentPrimary,
                        ),
                      ),
                      Text(
                        '$weekdayName • ${DualCalendarService.toGregorianString(_selectedDate)}',
                        style: TextStyle(
                          fontSize: 10,
                          color: widget.palette.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Calendar Toggle Button
              Row(
                children: [
                  InkWell(
                    onTap: _showAddEventDialog,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: widget.palette.bgElevated,
                        border: Border.all(color: widget.palette.borderSubtle),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '+ Reminder',
                        style: TextStyle(
                          fontSize: 11,
                          color: widget.palette.accentPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  InkWell(
                    onTap: () {
                      setState(() {
                        _isCalendarExpanded = !_isCalendarExpanded;
                      });
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: widget.palette.bgElevated,
                        border: Border.all(color: widget.palette.borderSubtle),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('📅 ', style: TextStyle(fontSize: 11)),
                          Text(
                            _isCalendarExpanded ? 'Close Calendar' : 'Shamsi Calendar',
                            style: TextStyle(
                              fontSize: 11,
                              color: widget.palette.textMain,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Quick Date Navigation Bar: [ « Week ] [ ‹ Day ] [ Today ] [ Day › ] [ Week » ]
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
            decoration: BoxDecoration(
              color: widget.palette.bgElevated,
              border: Border.all(color: widget.palette.borderSubtle),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildQuickNavButton(
                  label: '« Week',
                  onTap: () => _changeDate(_selectedDate.addDays(-7)),
                ),
                _buildQuickNavButton(
                  label: '‹ Day',
                  onTap: () => _changeDate(_selectedDate.addDays(-1)),
                ),
                _buildQuickNavButton(
                  label: 'Today',
                  isHighlighted: DateNavigationService.isToday(_selectedDate),
                  onTap: () => _changeDate(Jalali.now()),
                ),
                _buildQuickNavButton(
                  label: 'Day ›',
                  onTap: () => _changeDate(_selectedDate.addDays(1)),
                ),
                _buildQuickNavButton(
                  label: 'Week »',
                  onTap: () => _changeDate(_selectedDate.addDays(7)),
                ),
              ],
            ),
          ),

          // Collapsible Shamsi Month Grid (Strictly RTL)
          if (_isCalendarExpanded) ...[
            const SizedBox(height: 12),
            Directionality(
              textDirection: TextDirection.rtl, // RTL: شنبه (right) -> جمعه (left)
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: widget.palette.bgElevated,
                  border: Border.all(color: widget.palette.borderSubtle),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    // Weekday headers
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(7, (i) {
                        final isFriday = i == 6; // Far left in RTL is Friday
                        return Expanded(
                          child: Center(
                            child: Text(
                              _persianWeekdays[i][0], // ش، ی، د، س، چ، پ، ج
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isFriday
                                    ? const Color(0xFFEF4444)
                                    : widget.palette.textDim,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 6),

                    // Days grid
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                        childAspectRatio: 1.1,
                        crossAxisSpacing: 3,
                        mainAxisSpacing: 3,
                      ),
                      itemCount: monthLength,
                      itemBuilder: (context, index) {
                        final dayNum = index + 1;
                        final isSelected = dayNum == _selectedDate.day;
                        final hasEvents =
                            _dayHasEvent(_selectedDate.month, dayNum);

                        return InkWell(
                          onTap: () {
                            _changeDate(
                              Jalali(
                                _selectedDate.year,
                                _selectedDate.month,
                                dayNum,
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? widget.palette.accentPrimary
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Text(
                                  _toPersianDigits(dayNum),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isSelected
                                        ? Colors.black
                                        : widget.palette.textMain,
                                  ),
                                ),
                                if (hasEvents && !isSelected)
                                  Positioned(
                                    bottom: 2,
                                    child: Container(
                                      width: 4,
                                      height: 4,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFF59E0B),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 10),

          // Agenda Reminders & Checkpoints (Strictly RTL)
          Directionality(
            textDirection: TextDirection.ltr,
            child: selectedDayEvents.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      'No reminders or events scheduled for this day.',
                      style: TextStyle(
                        fontSize: 11,
                        color: widget.palette.textDim,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  )
                : Directionality(
                    textDirection: TextDirection.rtl,
                    child: Column(
                    children: selectedDayEvents.map((evt) {
                      Color bgColor;
                      Color borderColor;
                      Color textColor;
                      String icon;

                      switch (evt.category) {
                        case EventCategory.holiday:
                          bgColor = const Color(0x26F59E0B);
                          borderColor = const Color(0x66F59E0B);
                          textColor = const Color(0xFFFBBF24);
                          icon = '🏛️';
                          break;
                        case EventCategory.birthday:
                          bgColor = const Color(0x26EC4899);
                          borderColor = const Color(0x66EC4899);
                          textColor = const Color(0xFFF472B6);
                          icon = '🎂';
                          break;
                        case EventCategory.customDate:
                          bgColor = const Color(0x2060A5FA);
                          borderColor = const Color(0x5060A5FA);
                          textColor = const Color(0xFF93C5FD);
                          icon = '🎯';
                          break;
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: bgColor,
                          border: Border.all(color: borderColor),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Right side: Icon + Title
                            Expanded(
                              child: Row(
                                children: [
                                  Text(icon, style: const TextStyle(fontSize: 13)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      evt.title,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: evt.actionChecked
                                            ? textColor.withValues(alpha: 0.5)
                                            : textColor,
                                        decoration: evt.actionChecked
                                            ? TextDecoration.lineThrough
                                            : null,
                                        decorationColor: textColor,
                                        decorationThickness: 1.5,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Left side: Checkpoint Box
                            InkWell(
                              onTap: () => widget.onToggleCheckpoint(evt),
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: evt.actionChecked
                                      ? textColor
                                      : Colors.transparent,
                                  border: Border.all(
                                    color: textColor,
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: evt.actionChecked
                                    ? const Icon(
                                        Icons.check,
                                        size: 14,
                                        color: Colors.black,
                                      )
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
          ),
        ],
      ),
    );
  }
}
