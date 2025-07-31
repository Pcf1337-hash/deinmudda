import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
// removed unused import: package:flutter/foundation.dart // cleaned by BereinigungsAgent
import 'package:intl/intl.dart';
import '../models/entry.dart';
import '../widgets/glass_card.dart';
import '../widgets/timer_indicator.dart';
import '../theme/design_tokens.dart';
import '../theme/spacing.dart';
import '../utils/performance_helper.dart';

class AnimatedEntryCard extends StatefulWidget {
  final Entry entry;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final bool showActions;
  final bool isCompact;

  const AnimatedEntryCard({
    super.key,
    required this.entry,
    this.onTap,
    this.onDelete,
    this.showActions = true,
    this.isCompact = false,
  });

  @override
  State<AnimatedEntryCard> createState() => _AnimatedEntryCardState();
}

class _AnimatedEntryCardState extends State<AnimatedEntryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    // Adjust animation duration based on device capabilities
    final animationDuration = PerformanceHelper.getAnimationDuration(DesignTokens.animationFast);
    
    _animationController = AnimationController(
      duration: animationDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: DesignTokens.curveEaseOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.02, 0),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: DesignTokens.curveEaseOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _animationController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _animationController.reverse();
  }

  void _handleTapCancel() {
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.translate(
            offset: _slideAnimation.value,
            child: widget.isCompact
                ? _buildCompactCard(context)
                : _buildFullCard(context),
          ),
        );
      },
    );
  }

  Widget _buildCompactCard(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd.MM.yy HH:mm', 'de_DE');

    return GestureDetector(
      // Only use animations if they should be enabled
      onTapDown: (widget.onTap != null && PerformanceHelper.shouldEnableAnimations()) 
          ? _handleTapDown : null,
      onTapUp: (widget.onTap != null && PerformanceHelper.shouldEnableAnimations()) 
          ? _handleTapUp : null,
      onTapCancel: (widget.onTap != null && PerformanceHelper.shouldEnableAnimations()) 
          ? _handleTapCancel : null,
      onTap: widget.onTap,
      child: GlassCard(
        child: Row(
          children: [
            Container(
              width: 4,
              height: 50,
              decoration: BoxDecoration(
                color: _getSubstanceColor(widget.entry.substanceName),
                borderRadius: Spacing.borderRadiusSm,
              ),
            ),
            Spacing.horizontalSpaceMd,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.entry.substanceName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${widget.entry.dosage.toString().replaceAll('.', ',')} ${widget.entry.unit}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: DesignTokens.primaryIndigo,
                        ),
                      ),
                    ],
                  ),
                  Spacing.verticalSpaceXs,
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          dateFormat.format(widget.entry.dateTime),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                          ),
                        ),
                      ),
                      if (widget.entry.cost > 0)
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            '${widget.entry.cost.toStringAsFixed(2).replaceAll('.', ',')}€',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: DesignTokens.accentEmerald,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                          ),
                        ),
                    ],
                  ),
                  if (widget.entry.hasTimer) ...[
                    Spacing.verticalSpaceXs,
                    TimerIndicator(entry: widget.entry),
                  ],
                ],
              ),
            ),
            if (widget.showActions) ...[
              Spacing.horizontalSpaceSm,
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: Spacing.iconSm,
                color: theme.iconTheme.color?.withOpacity(0.5),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFullCard(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dateFormat = DateFormat('EEEE, d. MMMM yyyy', 'de_DE');
    final timeFormat = DateFormat('HH:mm', 'de_DE');

    return GestureDetector(
      onTapDown: widget.onTap != null ? _handleTapDown : null,
      onTapUp: widget.onTap != null ? _handleTapUp : null,
      onTapCancel: widget.onTap != null ? _handleTapCancel : null,
      onTap: widget.onTap,
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with substance name and actions
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(Spacing.xs),
                  decoration: BoxDecoration(
                    color: _getSubstanceColor(widget.entry.substanceName).withOpacity(0.1),
                    borderRadius: Spacing.borderRadiusSm,
                  ),
                  child: Icon(
                    _getSubstanceIcon(widget.entry.substanceName),
                    color: _getSubstanceColor(widget.entry.substanceName),
                    size: Spacing.iconMd,
                  ),
                ),
                Spacing.horizontalSpaceMd,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.entry.substanceName,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '${widget.entry.dosage.toString().replaceAll('.', ',')} ${widget.entry.unit}',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: DesignTokens.primaryIndigo,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.showActions)
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          widget.onTap?.call();
                          break;
                        case 'delete':
                          widget.onDelete?.call();
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_rounded),
                            SizedBox(width: 8),
                            Text('Bearbeiten'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_rounded, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Löschen', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                    child: Container(
                      padding: const EdgeInsets.all(Spacing.xs),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface.withOpacity(0.5),
                        borderRadius: Spacing.borderRadiusSm,
                      ),
                      child: Icon(
                        Icons.more_vert_rounded,
                        size: Spacing.iconSm,
                        color: theme.iconTheme.color?.withOpacity(0.7),
                      ),
                    ),
                  ),
              ],
            ),
            
            Spacing.verticalSpaceMd,
            
            // Date and time info
            Row(
              children: [
                Expanded(
                  child: _buildInfoChip(
                    context,
                    Icons.calendar_today_rounded,
                    dateFormat.format(widget.entry.dateTime),
                    DesignTokens.accentCyan,
                  ),
                ),
                Spacing.horizontalSpaceSm,
                Expanded(
                  child: _buildInfoChip(
                    context,
                    Icons.access_time_rounded,
                    timeFormat.format(widget.entry.dateTime),
                    DesignTokens.accentPurple,
                  ),
                ),
              ],
            ),
            
            if (widget.entry.cost > 0 || widget.entry.notes != null) ...[
              Spacing.verticalSpaceMd,
              
              // Cost and notes
              Row(
                children: [
                  if (widget.entry.cost > 0)
                    Expanded(
                      child: _buildInfoChip(
                        context,
                        Icons.euro_rounded,
                        '${widget.entry.cost.toStringAsFixed(2).replaceAll('.', ',')}€',
                        DesignTokens.accentEmerald,
                      ),
                    ),
                  if (widget.entry.cost > 0 && widget.entry.notes != null)
                    Spacing.horizontalSpaceSm,
                  if (widget.entry.notes != null)
                    Expanded(
                      child: _buildInfoChip(
                        context,
                        Icons.note_rounded,
                        'Notiz',
                        DesignTokens.warningYellow,
                      ),
                    ),
                ],
              ),
            ],
            
            if (widget.entry.notes != null) ...[
              Spacing.verticalSpaceMd,
              Container(
                width: double.infinity,
                padding: Spacing.paddingMd,
                decoration: BoxDecoration(
                  color: isDark
                      ? DesignTokens.neutral800.withOpacity(0.3)
                      : DesignTokens.neutral100.withOpacity(0.5),
                  borderRadius: Spacing.borderRadiusMd,
                  border: Border.all(
                    color: isDark
                        ? DesignTokens.neutral700
                        : DesignTokens.neutral200,
                    width: 1,
                  ),
                ),
                child: Text(
                  widget.entry.notes!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
            
            if (widget.entry.hasTimer) ...[
              Spacing.verticalSpaceMd,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TimerIndicator(entry: widget.entry),
                  Spacing.verticalSpaceXs,
                  TimerProgressBar(entry: widget.entry),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(
    BuildContext context,
    IconData icon,
    String text,
    Color color,
  ) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.sm,
        vertical: Spacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: Spacing.borderRadiusSm,
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: Spacing.iconSm,
            color: color,
          ),
          Spacing.horizontalSpaceXs,
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                text,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getSubstanceColor(String substanceName) {
    final hash = substanceName.hashCode;
    final colors = [
      DesignTokens.primaryIndigo,
      DesignTokens.accentCyan,
      DesignTokens.accentEmerald,
      DesignTokens.accentPurple,
      DesignTokens.warningYellow,
      DesignTokens.errorRed,
    ];
    return colors[hash.abs() % colors.length];
  }

  IconData _getSubstanceIcon(String substanceName) {
    final name = substanceName.toLowerCase();
    
    if (name.contains('kaffee') || name.contains('coffee')) {
      return Icons.local_cafe_rounded;
    } else if (name.contains('alkohol') || name.contains('bier') || name.contains('wein')) {
      return Icons.local_bar_rounded;
    } else if (name.contains('zigarette') || name.contains('tabak')) {
      return Icons.smoking_rooms_rounded;
    } else if (name.contains('medikament') || name.contains('tablette')) {
      return Icons.medication_rounded;
    } else if (name.contains('energie') || name.contains('energy')) {
      return Icons.flash_on_rounded;
    } else {
      return Icons.science_rounded;
    }
  }
}

// Compact version for use in lists
class CompactEntryCard extends StatelessWidget {
  final Entry entry;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const CompactEntryCard({
    super.key,
    required this.entry,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedEntryCard(
      entry: entry,
      onTap: onTap,
      onDelete: onDelete,
      isCompact: true,
    );
  }
}

// Skeleton loading state
class EntryCardSkeleton extends StatelessWidget {
  final bool isCompact;

  const EntryCardSkeleton({
    super.key,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GlassCard(
      child: isCompact
          ? _buildCompactSkeleton(isDark)
          : _buildFullSkeleton(isDark),
    );
  }

  Widget _buildCompactSkeleton(bool isDark) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.3),
            borderRadius: Spacing.borderRadiusSm,
          ),
        ),
        Spacing.horizontalSpaceMd,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.3),
                        borderRadius: Spacing.borderRadiusSm,
                      ),
                    ),
                  ),
                  Spacing.horizontalSpaceMd,
                  Container(
                    width: 60,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.3),
                      borderRadius: Spacing.borderRadiusSm,
                    ),
                  ),
                ],
              ),
              Spacing.verticalSpaceXs,
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.2),
                        borderRadius: Spacing.borderRadiusSm,
                      ),
                    ),
                  ),
                  Spacing.horizontalSpaceMd,
                  Container(
                    width: 40,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.2),
                      borderRadius: Spacing.borderRadiusSm,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ).animate(onPlay: (controller) => controller.repeat())
        .shimmer(duration: const Duration(milliseconds: 1500));
  }

  Widget _buildFullSkeleton(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: Spacing.borderRadiusSm,
              ),
            ),
            Spacing.horizontalSpaceMd,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.3),
                      borderRadius: Spacing.borderRadiusSm,
                    ),
                  ),
                  Spacing.verticalSpaceXs,
                  Container(
                    width: 100,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.2),
                      borderRadius: Spacing.borderRadiusSm,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Spacing.verticalSpaceMd,
        Row(
          children: [
            Expanded(
              child: Container(
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.2),
                  borderRadius: Spacing.borderRadiusSm,
                ),
              ),
            ),
            Spacing.horizontalSpaceSm,
            Expanded(
              child: Container(
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.2),
                  borderRadius: Spacing.borderRadiusSm,
                ),
              ),
            ),
          ],
        ),
      ],
    ).animate(onPlay: (controller) => controller.repeat())
        .shimmer(duration: const Duration(milliseconds: 1500));
  }
}
