enum EventCategory { holiday, birthday, customDate }

class ShamsiEvent {
  final String id;
  final String title;
  final int jalaliMonth; // 1-12
  final int jalaliDay; // 1-31
  final bool isOfficialHoliday;
  final bool isEnabled;
  final bool isCustom;
  final bool actionChecked;
  final EventCategory category;
  final String? note;

  const ShamsiEvent({
    required this.id,
    required this.title,
    required this.jalaliMonth,
    required this.jalaliDay,
    this.isOfficialHoliday = false,
    this.isEnabled = true,
    this.isCustom = false,
    this.actionChecked = false,
    this.category = EventCategory.customDate,
    this.note,
  });

  ShamsiEvent copyWith({
    String? id,
    String? title,
    int? jalaliMonth,
    int? jalaliDay,
    bool? isOfficialHoliday,
    bool? isEnabled,
    bool? isCustom,
    bool? actionChecked,
    EventCategory? category,
    String? note,
  }) {
    return ShamsiEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      jalaliMonth: jalaliMonth ?? this.jalaliMonth,
      jalaliDay: jalaliDay ?? this.jalaliDay,
      isOfficialHoliday: isOfficialHoliday ?? this.isOfficialHoliday,
      isEnabled: isEnabled ?? this.isEnabled,
      isCustom: isCustom ?? this.isCustom,
      actionChecked: actionChecked ?? this.actionChecked,
      category: category ?? this.category,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'jalaliMonth': jalaliMonth,
      'jalaliDay': jalaliDay,
      'isOfficialHoliday': isOfficialHoliday,
      'isEnabled': isEnabled,
      'isCustom': isCustom,
      'actionChecked': actionChecked,
      'category': category.name,
      'note': note,
    };
  }

  factory ShamsiEvent.fromJson(Map<String, dynamic> json) {
    return ShamsiEvent(
      id: json['id'] as String,
      title: json['title'] as String,
      jalaliMonth: json['jalaliMonth'] as int,
      jalaliDay: json['jalaliDay'] as int,
      isOfficialHoliday: (json['isOfficialHoliday'] as bool?) ?? false,
      isEnabled: (json['isEnabled'] as bool?) ?? true,
      isCustom: (json['isCustom'] as bool?) ?? false,
      actionChecked: (json['actionChecked'] as bool?) ?? false,
      category: EventCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => EventCategory.customDate,
      ),
      note: json['note'] as String?,
    );
  }

  /// Default Iranian Solar Hijri holidays and notable dates
  static List<ShamsiEvent> get defaultEvents {
    return [
      // Farvardin
      const ShamsiEvent(
        id: 'h_far_01',
        title: 'جشن نوروز / سال نو (تعطیل رسمی)',
        jalaliMonth: 1,
        jalaliDay: 1,
        isOfficialHoliday: true,
        category: EventCategory.holiday,
      ),
      const ShamsiEvent(
        id: 'h_far_02',
        title: 'عید نوروز (تعطیل رسمی)',
        jalaliMonth: 1,
        jalaliDay: 2,
        isOfficialHoliday: true,
        category: EventCategory.holiday,
      ),
      const ShamsiEvent(
        id: 'h_far_03',
        title: 'عید نوروز (تعطیل رسمی)',
        jalaliMonth: 1,
        jalaliDay: 3,
        isOfficialHoliday: true,
        category: EventCategory.holiday,
      ),
      const ShamsiEvent(
        id: 'h_far_04',
        title: 'عید نوروز (تعطیل رسمی)',
        jalaliMonth: 1,
        jalaliDay: 4,
        isOfficialHoliday: true,
        category: EventCategory.holiday,
      ),
      const ShamsiEvent(
        id: 'h_far_12',
        title: 'روز جمهوری اسلامی (تعطیل رسمی)',
        jalaliMonth: 1,
        jalaliDay: 12,
        isOfficialHoliday: true,
        category: EventCategory.holiday,
      ),
      const ShamsiEvent(
        id: 'h_far_13',
        title: 'روز طبیعت - سیزده‌بدر (تعطیل رسمی)',
        jalaliMonth: 1,
        jalaliDay: 13,
        isOfficialHoliday: true,
        category: EventCategory.holiday,
      ),

      // Khordad
      const ShamsiEvent(
        id: 'h_khor_14',
        title: 'رحلت امام خمینی (تعطیل رسمی)',
        jalaliMonth: 3,
        jalaliDay: 14,
        isOfficialHoliday: true,
        category: EventCategory.holiday,
      ),
      const ShamsiEvent(
        id: 'h_khor_15',
        title: 'قیام ۱۵ خرداد (تعطیل رسمی)',
        jalaliMonth: 3,
        jalaliDay: 15,
        isOfficialHoliday: true,
        category: EventCategory.holiday,
      ),

      // Mordad
      const ShamsiEvent(
        id: 'h_mor_28',
        title: 'سالروز کودتای ۲۸ مرداد',
        jalaliMonth: 5,
        jalaliDay: 28,
        isOfficialHoliday: false,
        category: EventCategory.holiday,
      ),

      // Mehr / Aban
      const ShamsiEvent(
        id: 'h_aban_23',
        title: 'روز دختر و ولادت حضرت معصومه (س)',
        jalaliMonth: 8,
        jalaliDay: 23,
        isOfficialHoliday: false,
        category: EventCategory.holiday,
      ),

      // Bahman
      const ShamsiEvent(
        id: 'h_bah_22',
        title: 'پیروزی انقلاب اسلامی (تعطیل رسمی)',
        jalaliMonth: 11,
        jalaliDay: 22,
        isOfficialHoliday: true,
        category: EventCategory.holiday,
      ),

      // Esfand
      const ShamsiEvent(
        id: 'h_esf_29',
        title: 'روز ملی شدن صنعت نفت ایران (تعطیل رسمی)',
        jalaliMonth: 12,
        jalaliDay: 29,
        isOfficialHoliday: true,
        category: EventCategory.holiday,
      ),

      // Sample user birthdays / dates
      const ShamsiEvent(
        id: 'b_maryam',
        title: 'تولد مریم (Mary\'s Birthday)',
        jalaliMonth: 8,
        jalaliDay: 23,
        isOfficialHoliday: false,
        isCustom: true,
        actionChecked: true,
        category: EventCategory.birthday,
        note: 'تماس گرفته شد و تبریک گفتم',
      ),
      const ShamsiEvent(
        id: 'c_exam',
        title: 'Final Exam Submission (14:00)',
        jalaliMonth: 8,
        jalaliDay: 23,
        isOfficialHoliday: false,
        isCustom: true,
        actionChecked: false,
        category: EventCategory.customDate,
      ),
    ];
  }
}
