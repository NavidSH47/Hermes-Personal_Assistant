import 'package:flutter/material.dart';

enum MediaType { book, tvShow, movie, videoGame }

class MediaItem {
  final String id;
  final MediaType type;
  final String title;
  final int releaseYear;
  final String? coverUrl;
  final String? localCoverPath;
  final double progressCurrent;
  final double progressTotal;
  final double? score; // 1.0 - 10.0 in 0.5 steps
  final bool isOnHold;
  final int customOrder;
  final DateTime createdAt;

  MediaItem({
    required this.id,
    required this.type,
    required this.title,
    required this.releaseYear,
    this.coverUrl,
    this.localCoverPath,
    required this.progressCurrent,
    required this.progressTotal,
    this.score,
    this.isOnHold = false,
    this.customOrder = 0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  double get progressRatio {
    if (progressTotal <= 0) return 0.0;
    final r = progressCurrent / progressTotal;
    return r.clamp(0.0, 1.0);
  }

  int get progressPercent => (progressRatio * 100).round();

  String get metricUnit {
    switch (type) {
      case MediaType.book:
        return 'Pages';
      case MediaType.tvShow:
        return 'Episodes';
      case MediaType.movie:
        return 'Minutes';
      case MediaType.videoGame:
        return 'Chapters/Missions';
    }
  }

  String get metricDisplay {
    final cur = progressCurrent.toInt();
    final tot = progressTotal.toInt();
    switch (type) {
      case MediaType.book:
        return 'Pages: $cur / $tot';
      case MediaType.tvShow:
        return 'Episodes: $cur / $tot';
      case MediaType.movie:
        return 'Minutes: $cur / $tot min';
      case MediaType.videoGame:
        return 'Missions: $cur / $tot';
    }
  }

  String get iconEmoji {
    switch (type) {
      case MediaType.book:
        return '📖';
      case MediaType.tvShow:
        return '📺';
      case MediaType.movie:
        return '🎬';
      case MediaType.videoGame:
        return '🎮';
    }
  }

  List<Color> get scoreGradient {
    if (score == null) {
      return [const Color(0xFF64748B), const Color(0xFF475569)];
    }
    final s = score!;
    if (s <= 3.5) {
      return [const Color(0xFFE53935), const Color(0xFFFF7043)];
    } else if (s <= 6.5) {
      return [const Color(0xFFFFA000), const Color(0xFFC0CA33)];
    } else if (s <= 8.5) {
      return [const Color(0xFF26A69A), const Color(0xFF43A047)];
    } else {
      return [const Color(0xFF2E7D32), const Color(0xFF7E57C2)];
    }
  }

  MediaItem copyWith({
    String? id,
    MediaType? type,
    String? title,
    int? releaseYear,
    String? coverUrl,
    String? localCoverPath,
    double? progressCurrent,
    double? progressTotal,
    double? score,
    bool? isOnHold,
    int? customOrder,
    DateTime? createdAt,
  }) {
    return MediaItem(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      releaseYear: releaseYear ?? this.releaseYear,
      coverUrl: coverUrl ?? this.coverUrl,
      localCoverPath: localCoverPath ?? this.localCoverPath,
      progressCurrent: progressCurrent ?? this.progressCurrent,
      progressTotal: progressTotal ?? this.progressTotal,
      score: score ?? this.score,
      isOnHold: isOnHold ?? this.isOnHold,
      customOrder: customOrder ?? this.customOrder,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'title': title,
      'releaseYear': releaseYear,
      'coverUrl': coverUrl,
      'localCoverPath': localCoverPath,
      'progressCurrent': progressCurrent,
      'progressTotal': progressTotal,
      'score': score,
      'isOnHold': isOnHold,
      'customOrder': customOrder,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory MediaItem.fromJson(Map<String, dynamic> json) {
    return MediaItem(
      id: json['id'] as String,
      type: MediaType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => MediaType.book,
      ),
      title: json['title'] as String,
      releaseYear: (json['releaseYear'] as int?) ?? 2024,
      coverUrl: json['coverUrl'] as String?,
      localCoverPath: json['localCoverPath'] as String?,
      progressCurrent: (json['progressCurrent'] as num?)?.toDouble() ?? 0.0,
      progressTotal: (json['progressTotal'] as num?)?.toDouble() ?? 100.0,
      score: (json['score'] as num?)?.toDouble(),
      isOnHold: (json['isOnHold'] as bool?) ?? false,
      customOrder: (json['customOrder'] as int?) ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
