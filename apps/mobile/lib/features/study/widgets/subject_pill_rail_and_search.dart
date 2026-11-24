import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/ui/animations/bounceable.dart';
import '../models/study_models.dart';

/// Subject Pill Rail, Instant Search, and Cupertino Segmented Filter Bar
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
    final raisedBg = isDark ? const Color(0xFF2B2B31) : Colors.white;
    final lineBorder = isDark ? const Color(0xFF2B2B31) : const Color(0xFFE4E4E8);
    final subtextColor = isDark ? AppColors.darkSubtext : AppColors.lightSubtext;

    final isSearchFocused = _searchFocusNode.hasFocus;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // =====================================================================
        // 1. HORIZONTAL SCROLLABLE SUBJECT PILL RAIL
        // =====================================================================
        SizedBox(
          height: 38,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: widget.subjects.length,
            separatorBuilder: (_, i) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final subject = widget.subjects[index];
              final isActive = subject.id == widget.activeSubjectId;

              return AcedexBounceable(
                onTap: () => widget.onSelectSubject(subject.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: isActive ? primaryColor : surfaceColor,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: isActive ? primaryColor : lineBorder,
                      width: 1.2,
                    ),
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: primaryColor.withValues(alpha: 0.35),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      HugeIcon(
                        icon: subject.iconData,
                        color: isActive ? Colors.white : theme.colorScheme.onSurface,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        subject.name,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                          color: isActive ? Colors.white : theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: isActive
                              ? Colors.white.withValues(alpha: 0.22)
                              : raisedBg,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '${subject.mastery}%',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: isActive ? Colors.white : primaryColor,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 10),

        // =====================================================================
        // 2. INSTANT SEARCH INPUT BAR
        // =====================================================================
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 11),
          decoration: BoxDecoration(
            color: isSearchFocused ? raisedBg : surfaceColor,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color: isSearchFocused ? primaryColor : lineBorder,
              width: isSearchFocused ? 1.4 : 1.0,
            ),
            boxShadow: isSearchFocused
                ? [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.10),
                      blurRadius: 8,
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
                size: 15,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  focusNode: _searchFocusNode,
                  controller: widget.searchController,
                  cursorColor: primaryColor,
                  style: TextStyle(
                    fontSize: 12.5,
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
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: lineBorder,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: HugeIcon(
                      icon: HugeIcons.strokeRoundedCancel01,
                      color: theme.colorScheme.onSurface,
                      size: 10,
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
          height: 32,
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: lineBorder),
          ),
          child: Stack(
            children: [
              AnimatedAlign(
                duration: const Duration(milliseconds: 320),
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
                      borderRadius: BorderRadius.circular(8.5),
                      border: Border.all(color: lineBorder),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
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
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isActive ? primaryColor : subtextColor,
              ),
            ),
            if (badgeCount != null) ...[
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$badgeCount',
                  style: TextStyle(
                    fontSize: 9,
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
