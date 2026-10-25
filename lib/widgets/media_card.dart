import 'package:flutter/material.dart';
import '../models/media_item.dart';
import '../theme/app_theme.dart';

class MediaCard extends StatelessWidget {
  final MediaItem item;
  final VibePalette palette;
  final bool isGrid;
  final Function(bool) onToggleOnHold;
  final VoidCallback onUpdateProgress;
  final VoidCallback onEditCover;
  final VoidCallback? onDelete;

  const MediaCard({
    super.key,
    required this.item,
    required this.palette,
    this.isGrid = false,
    required this.onToggleOnHold,
    required this.onUpdateProgress,
    required this.onEditCover,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (isGrid) {
      return _buildGridCard(context);
    }
    return _buildListCard(context);
  }

  // --- LIST VIEW CARD (Horizontal) ---
  Widget _buildListCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: palette.bgElevated,
        border: Border.all(
          color: item.isOnHold
              ? const Color(0x66F59E0B)
              : palette.borderSubtle,
          width: item.isOnHold ? 1.5 : 1.0,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover Box
              _buildCoverBox(width: 74, height: 104),
              const SizedBox(width: 12),

              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Title & Year
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: palette.textMain,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '${item.releaseYear}',
                          style: TextStyle(
                            fontSize: 11,
                            color: palette.textDim,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    // Score Badge
                    _buildScoreBadge(),

                    const SizedBox(height: 8),

                    // Progress Section
                    _buildProgressSection(),

                    const SizedBox(height: 8),

                    // Foot Actions: On-hold + Update Progress
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () => onToggleOnHold(!item.isOnHold),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 18,
                                height: 18,
                                child: Checkbox(
                                  value: item.isOnHold,
                                  onChanged: (val) =>
                                      onToggleOnHold(val ?? false),
                                  activeColor: const Color(0xFFF59E0B),
                                  side: BorderSide(
                                    color: palette.textDim,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'On-hold',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: item.isOnHold
                                      ? const Color(0xFFFBBF24)
                                      : palette.textDim,
                                  fontWeight: item.isOnHold
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: onUpdateProgress,
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: palette.bgSurface,
                              border: Border.all(color: palette.borderSubtle),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '+ Update',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: palette.accentPrimary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          // On-hold top corner chip
          if (item.isOnHold)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0x33F59E0B),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'ON-HOLD',
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFFBBF24),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // --- GRID VIEW CARD (2-Column Poster-first) ---
  Widget _buildGridCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: palette.bgElevated,
        border: Border.all(
          color: item.isOnHold
              ? const Color(0x66F59E0B)
              : palette.borderSubtle,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Poster Cover Box on top
          Expanded(
            child: _buildCoverBox(width: double.infinity, height: double.infinity),
          ),

          const SizedBox(height: 8),

          // Title & Year
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  item.title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: palette.textMain,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${item.releaseYear}',
                style: TextStyle(fontSize: 10, color: palette.textDim),
              ),
            ],
          ),

          const SizedBox(height: 4),

          // Score Badge
          _buildScoreBadge(),

          const SizedBox(height: 6),

          // Progress
          _buildProgressSection(),

          const SizedBox(height: 6),

          // Action row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () => onToggleOnHold(!item.isOnHold),
                child: Text(
                  item.isOnHold ? '⏸ On-hold' : '▶ Active',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: item.isOnHold
                        ? const Color(0xFFFBBF24)
                        : palette.accentPrimary,
                  ),
                ),
              ),
              InkWell(
                onTap: onUpdateProgress,
                child: Text(
                  '+ Update',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: palette.textMain,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCoverBox({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            palette.bgSurface,
            palette.bgElevated,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: palette.borderSubtle),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        alignment: Alignment.center,
        children: [
          if (item.coverUrl != null && item.coverUrl!.isNotEmpty)
            Image.network(
              item.coverUrl!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  _buildPlaceholderEmoji(),
            )
          else
            _buildPlaceholderEmoji(),

          // Hover / Tap "Edit Cover" Overlay
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: InkWell(
              onTap: onEditCover,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 3),
                color: const Color(0xA6000000),
                child: const Text(
                  'Edit Cover',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderEmoji() {
    return Center(
      child: Text(
        item.iconEmoji,
        style: const TextStyle(fontSize: 28),
      ),
    );
  }

  Widget _buildScoreBadge() {
    final colors = item.scoreGradient;
    final scoreText = item.score != null
        ? '⭐ ${item.score!.toStringAsFixed(1)} / 10'
        : '⭐ No Rating';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: colors.first.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Text(
        scoreText,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildProgressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              item.metricDisplay,
              style: TextStyle(fontSize: 10, color: palette.textMuted),
            ),
            Text(
              '${item.progressPercent}%',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: palette.textMain,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          height: 5,
          decoration: BoxDecoration(
            color: const Color(0x14FFFFFF),
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: item.progressRatio,
            child: Container(
              decoration: BoxDecoration(
                gradient: palette.accentGradient,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
