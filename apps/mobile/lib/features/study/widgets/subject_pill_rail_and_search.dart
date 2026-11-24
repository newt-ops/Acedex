import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/ui/animations/bounceable.dart';
import '../models/study_models.dart';

/// Spacious Apple Bento Subject Switcher Rail, Instant Search, and Cupertino Segmented Filter Bar
class SubjectPillRailAndSearch extends StatefulWidget {
  final List<SubjectCurriculum> subjects;
  final String activeSubjectId;
  final ValueChanged<String> onSelectSubject;

  final TextEditingController searchController;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;

  final String activeFilter; // 'all' | 'progress' | 'bookmarked'
  final ValueChanged<String> onFilterChanged;
  final int bookmarkedCount;

  const SubjectPillRailAndSearch({
    super.key,
    required this.subjects,
    required this.activeSubjectId,
    required this.onSelectSubject,
    required this.searchController,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.activeFilter,
    required this.onFilterChanged,
    required this.bookmarkedCount,
  });

  @override
  State<SubjectPillRailAndSearch> createState() => _SubjectPillRailAndSearchState();
}

class _SubjectPillRailAndSearchState extends State<SubjectPillRailAndSearch> {
  late final FocusNode _searchFocusNode;

  @override
  void initState() {
    super.initState();
    _searchFocusNode = FocusNode();
    _searchFocusNode.addListener(_handleFocusChanged);
  }

  void _handleFocusChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _searchFocusNode.removeListener(_handleFocusChanged);
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;
    final surfaceColor = isDark ? const Color(0xFF1B1B1F) : const Color(0xFFF4F4F6);
    final raisedBg = isDark ? const Color(0xFF25252B) : Colors.white;
    final lineBorder = isDark ? const Color(0xFF33333E) : const Color(0xFFE4E4E8);
    final subtextColor = isDark ? AppColors.darkSubtext : AppColors.lightSubtext;

    final isSearchFocused = _searchFocusNode.hasFocus;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // =====================================================================
        // 1. SPACIOUS APPLE BENTO SUBJECT SWITCHER RAIL (144px Cards, 22px Radius)
        // =====================================================================
        SizedBox(
          height: 122,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: widget.subjects.length,
            separatorBuilder: (_, i) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final subject = widget.subjects[index];
              final isActive = subject.id == widget.activeSubjectId;

              final totalUnits = subject.units.length;
              final doneUnits = subject.units.where((u) => u.isCompleted).length;

              return AcedexBounceable(
                onTap: () => widget.onSelectSubject(subject.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  width: 144,
                  padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
                  decoration: BoxDecoration(
                    color: isActive ? primaryColor : surfaceColor,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: isActive ? primaryColor : lineBorder,
                      width: 1.2,
                    ),
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: primaryColor.withValues(alpha: isDark ? 0.42 : 0.28),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Top Row: Icon Squircle + Mastery Percentage
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? Colors.white.withValues(alpha: 0.22)
                                  : raisedBg,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isActive
                                    ? Colors.white.withValues(alpha: 0.25)
                                    : lineBorder,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: HugeIcon(
                              icon: subject.iconData,
                              color: isActive ? Colors.white : primaryColor,
                              size: 16,
                            ),
                          ),
                          Text(
                            '${subject.mastery}%',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.2,
                              color: isActive ? Colors.white : primaryColor,
                              fontFeatures: const [FontFeature.tabularFigures()],
                            ),
                          ),
                        ],
                      ),

                      // Bottom Group: Subject Name + Mini Progress Bar + Subtitle
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            subject.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.2,
                              color: isActive ? Colors.white : theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: Container(
                              height: 4,
                              width: double.infinity,
                              color: isActive
                                  ? Colors.white.withValues(alpha: 0.25)
                                  : primaryColor.withValues(alpha: 0.12),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: FractionallySizedBox(
                                  widthFactor: (subject.mastery / 100).clamp(0.0, 1.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: isActive ? Colors.white : primaryColor,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 3.5),
                          Text(
                            totalUnits > 0
                                ? '$doneUnits/$totalUnits Units Done'
                                : '${subject.mastery}% Mastered',
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w600,
                              color: isActive
                                  ? Colors.white.withValues(alpha: 0.85)
                                  : subtextColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 12),

        // =====================================================================
        // 2. INSTANT APPLE SEARCH BAR (Single-Layer Squircle, Zero Double-Borders)
        // =====================================================================
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: isSearchFocused ? raisedBg : surfaceColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSearchFocused ? primaryColor : lineBorder,
              width: isSearchFocused ? 1.4 : 1.0,
            ),
            boxShadow: isSearchFocused
                ? [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.12),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              HugeIcon(
                icon: HugeIcons.strokeRoundedSearch01,
                color: isSearchFocused ? primaryColor : subtextColor,
                size: 16,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: TextField(
                  focusNode: _searchFocusNode,
                  controller: widget.searchController,
                  cursorColor: primaryColor,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    filled: false,
                    fillColor: Colors.transparent,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    hintText: 'Search units, topics, formulas...',
                    hintStyle: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: subtextColor,
                    ),
                  ),
                  onChanged: widget.onSearchChanged,
                ),
              ),
              if (widget.searchQuery.isNotEmpty)
                GestureDetector(
                  onTap: widget.onClearSearch,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: lineBorder,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: HugeIcon(
                      icon: HugeIcons.strokeRoundedCancel01,
                      color: theme.colorScheme.onSurface,
                      size: 11,
                    ),
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        // =====================================================================
        // 3. GLIDING CUPERTINO 3-OPTION SEGMENTED FILTER BAR
        // =====================================================================
        Container(
          height: 34,
          padding: const EdgeInsets.all(2.5),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: lineBorder),
          ),
          child: Stack(
            children: [
              AnimatedAlign(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                alignment: widget.activeFilter == 'all'
                    ? Alignment.centerLeft
                    : (widget.activeFilter == 'progress'
                        ? Alignment.center
                        : Alignment.centerRight),
                child: FractionallySizedBox(
                  widthFactor: 1 / 3,
                  child: Container(
                    decoration: BoxDecoration(
                      color: raisedBg,
                      borderRadius: BorderRadius.circular(9.5),
                      border: Border.all(color: lineBorder),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildFilterTab(
                      label: 'All Units',
                      filterKey: 'all',
                      isActive: widget.activeFilter == 'all',
                      primaryColor: primaryColor,
                      subtextColor: subtextColor,
                    ),
                  ),
                  Expanded(
                    child: _buildFilterTab(
                      label: 'In Progress',
                      filterKey: 'progress',
                      isActive: widget.activeFilter == 'progress',
                      primaryColor: primaryColor,
                      subtextColor: subtextColor,
                    ),
                  ),
                  Expanded(
                    child: _buildFilterTab(
                      label: 'Bookmarked',
                      filterKey: 'bookmarked',
                      isActive: widget.activeFilter == 'bookmarked',
                      primaryColor: primaryColor,
                      subtextColor: subtextColor,
                      badgeCount: widget.bookmarkedCount,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterTab({
    required String label,
    required String filterKey,
    required bool isActive,
    required Color primaryColor,
    required Color subtextColor,
    int? badgeCount,
  }) {
    return GestureDetector(
      onTap: () => widget.onFilterChanged(filterKey),
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                color: isActive ? primaryColor : subtextColor,
              ),
            ),
            if (badgeCount != null && badgeCount > 0) ...[
              const SizedBox(width: 4.5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5.5, vertical: 1),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$badgeCount',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: primaryColor,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
