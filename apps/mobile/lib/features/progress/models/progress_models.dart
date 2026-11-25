/// Analytics timeframe options
enum ProgressTimeframe {
  sevenDays('7d', '7 Days'),
  thirtyDays('30d', '30 Days'),
  allTerm('term', 'All Term');

  final String key;
  final String label;
  const ProgressTimeframe(this.key, this.label);
}

/// Readiness Pillar types
enum ReadinessPillarType {
  coverage('Syllabus Coverage'),
  accuracy('Mock Accuracy'),
  consistency('Consistency');

  final String title;
  const ReadinessPillarType(this.title);
}

/// Chart metric toggle
enum ChartMetricType {
  hours('Study Hours'),
  accuracy('Quiz Accuracy');

  final String label;
  const ChartMetricType(this.label);
}

/// Single data point for the 7-period chart
class TimeframePoint {
  final String dateKey;
  final String short;
  final String label;
  final double hours;
  final int minutes;
  final int qs;
  final int acc;

  const TimeframePoint({
    this.dateKey = '',
    required this.short,
    required this.label,
    required this.hours,
    this.minutes = 0,
    required this.qs,
    required this.acc,
  });

  factory TimeframePoint.fromJson(Map<String, dynamic> json) {
    final hoursVal = (json['hours'] as num?)?.toDouble() ?? 0.0;
    final minsVal = (json['minutes'] as num?)?.toInt() ?? (hoursVal * 60).round();
    return TimeframePoint(
      dateKey: json['dateKey'] as String? ?? '',
      short: json['short'] as String? ?? '',
      label: json['label'] as String? ?? '',
      hours: hoursVal,
      minutes: minsVal,
      qs: (json['qs'] as num?)?.toInt() ?? 0,
      acc: (json['acc'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'dateKey': dateKey,
        'short': short,
        'label': label,
        'hours': hours,
        'minutes': minutes,
        'qs': qs,
        'acc': acc,
      };
}

/// Complete live dataset for a selected timeframe
class TimeframeData {
  final int readinessPct;
  final int projectedScore;
  final String percentile;
  final String delta;
  final String subcopy;
  final int coveragePct;
  final int accuracyPct;
  final int consistencyPct;
  final int completedUnits;
  final int totalUnits;
  final int assessmentsCount;
  final int dailyGoalMinutes;
  final int activeDays;
  final int windowDays;
  final String footerHours;
  final String footerAcc;
  final String footerQs;
  final List<TimeframePoint> points;

  const TimeframeData({
    required this.readinessPct,
    required this.projectedScore,
    required this.percentile,
    required this.delta,
    required this.subcopy,
    required this.coveragePct,
    required this.accuracyPct,
    required this.consistencyPct,
    this.completedUnits = 0,
    this.totalUnits = 0,
    this.assessmentsCount = 0,
    this.dailyGoalMinutes = 60,
    this.activeDays = 0,
    this.windowDays = 7,
    required this.footerHours,
    required this.footerAcc,
    required this.footerQs,
    required this.points,
  });

  factory TimeframeData.fromJson(Map<String, dynamic> json) {
    final rawPoints = (json['points'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(TimeframePoint.fromJson)
        .toList();
    return TimeframeData(
      readinessPct: (json['readinessPct'] as num?)?.toInt() ?? 0,
      projectedScore: (json['projectedScore'] as num?)?.toInt() ?? 0,
      percentile: json['percentile'] as String? ?? 'Baseline',
      delta: json['delta'] as String? ?? '+0.0%',
      subcopy: json['subcopy'] as String? ??
          'Complete units & assessments to build your live EUEE projection.',
      coveragePct: (json['coveragePct'] as num?)?.toInt() ?? 0,
      accuracyPct: (json['accuracyPct'] as num?)?.toInt() ?? 0,
      consistencyPct: (json['consistencyPct'] as num?)?.toInt() ?? 0,
      completedUnits: (json['completedUnits'] as num?)?.toInt() ?? 0,
      totalUnits: (json['totalUnits'] as num?)?.toInt() ?? 0,
      assessmentsCount: (json['assessmentsCount'] as num?)?.toInt() ?? 0,
      dailyGoalMinutes: (json['dailyGoalMinutes'] as num?)?.toInt() ?? 60,
      activeDays: (json['activeDays'] as num?)?.toInt() ?? 0,
      windowDays: (json['windowDays'] as num?)?.toInt() ?? 7,
      footerHours: json['footerHours'] as String? ?? '0.0 hrs',
      footerAcc: json['footerAcc'] as String? ?? '0.0%',
      footerQs: json['footerQs'] as String? ?? '0 Qs',
      points: rawPoints,
    );
  }

  Map<String, dynamic> toJson() => {
        'readinessPct': readinessPct,
        'projectedScore': projectedScore,
        'percentile': percentile,
        'delta': delta,
        'subcopy': subcopy,
        'coveragePct': coveragePct,
        'accuracyPct': accuracyPct,
        'consistencyPct': consistencyPct,
        'completedUnits': completedUnits,
        'totalUnits': totalUnits,
        'assessmentsCount': assessmentsCount,
        'dailyGoalMinutes': dailyGoalMinutes,
        'activeDays': activeDays,
        'windowDays': windowDays,
        'footerHours': footerHours,
        'footerAcc': footerAcc,
        'footerQs': footerQs,
        'points': points.map((p) => p.toJson()).toList(),
      };
}

/// Single day cell for the 28-day consistency heatmap
class HeatmapDay {
  final String dateKey;
  final String date;
  final String weekdayShort;
  final double hours;
  final int minutes;
  final int qs;
  final int acc;
  final int level; // 0 to 4

  const HeatmapDay({
    this.dateKey = '',
    required this.date,
    this.weekdayShort = 'M',
    required this.hours,
    this.minutes = 0,
    this.qs = 0,
    required this.acc,
    required this.level,
  });

  factory HeatmapDay.fromJson(Map<String, dynamic> json) {
    final hoursVal = (json['hours'] as num?)?.toDouble() ?? 0.0;
    final minsVal = (json['minutes'] as num?)?.toInt() ?? (hoursVal * 60).round();
    return HeatmapDay(
      dateKey: json['dateKey'] as String? ?? '',
      date: json['date'] as String? ?? '',
      weekdayShort: json['weekdayShort'] as String? ?? 'M',
      hours: hoursVal,
      minutes: minsVal,
      qs: (json['qs'] as num?)?.toInt() ?? 0,
      acc: (json['acc'] as num?)?.toInt() ?? 0,
      level: ((json['level'] as num?)?.toInt() ?? 0).clamp(0, 4),
    );
  }

  Map<String, dynamic> toJson() => {
        'dateKey': dateKey,
        'date': date,
        'weekdayShort': weekdayShort,
        'hours': hours,
        'minutes': minutes,
        'qs': qs,
        'acc': acc,
        'level': level,
      };
}

/// EUEE simulator subject baseline (6 subjects including English + SAT)
class SimulatorSubjectScore {
  final String id;
  final String code;
  final String name;
  final int score;

  const SimulatorSubjectScore({
    required this.id,
    required this.code,
    required this.name,
    required this.score,
  });

  factory SimulatorSubjectScore.fromJson(Map<String, dynamic> json) {
    return SimulatorSubjectScore(
      id: json['id'] as String? ?? '',
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      score: ((json['score'] as num?)?.toInt() ?? 0).clamp(0, 100),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'name': name,
        'score': score,
      };
}

/// Complete live progress analytics bundle
class ProgressAnalyticsData {
  final String stream;
  final int dailyGoalMinutes;
  final int currentStreak;
  final int longestStreak;
  final Map<ProgressTimeframe, TimeframeData> timeframes;
  final List<HeatmapDay> heatmapDays;
  final List<SimulatorSubjectScore> simulatorSubjects;

  const ProgressAnalyticsData({
    required this.stream,
    required this.dailyGoalMinutes,
    required this.currentStreak,
    required this.longestStreak,
    required this.timeframes,
    required this.heatmapDays,
    required this.simulatorSubjects,
  });

  factory ProgressAnalyticsData.fromJson(Map<String, dynamic> json) {
    final streak = json['streak'] as Map<String, dynamic>? ?? const {};
    final tfMap = json['timeframes'] as Map<String, dynamic>? ?? const {};

    final parsedTimeframes = <ProgressTimeframe, TimeframeData>{
      ProgressTimeframe.sevenDays: TimeframeData.fromJson(
        tfMap['7d'] as Map<String, dynamic>? ?? const {},
      ),
      ProgressTimeframe.thirtyDays: TimeframeData.fromJson(
        tfMap['30d'] as Map<String, dynamic>? ?? const {},
      ),
      ProgressTimeframe.allTerm: TimeframeData.fromJson(
        tfMap['term'] as Map<String, dynamic>? ?? const {},
      ),
    };

    final rawHeatmap = (json['heatmapDays'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(HeatmapDay.fromJson)
        .toList();

    final rawSim = (json['simulatorSubjects'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(SimulatorSubjectScore.fromJson)
        .toList();

    return ProgressAnalyticsData(
      stream: (json['stream'] as String? ?? 'natural').toLowerCase(),
      dailyGoalMinutes: (json['dailyGoalMinutes'] as num?)?.toInt() ?? 60,
      currentStreak: (streak['currentStreak'] as num?)?.toInt() ?? 0,
      longestStreak: (streak['longestStreak'] as num?)?.toInt() ?? 0,
      timeframes: parsedTimeframes,
      heatmapDays: rawHeatmap,
      simulatorSubjects: rawSim,
    );
  }

  Map<String, dynamic> toJson() => {
        'stream': stream,
        'dailyGoalMinutes': dailyGoalMinutes,
        'streak': {
          'currentStreak': currentStreak,
          'longestStreak': longestStreak,
        },
        'timeframes': {
          '7d': timeframes[ProgressTimeframe.sevenDays]?.toJson(),
          '30d': timeframes[ProgressTimeframe.thirtyDays]?.toJson(),
          'term': timeframes[ProgressTimeframe.allTerm]?.toJson(),
        },
        'heatmapDays': heatmapDays.map((d) => d.toJson()).toList(),
        'simulatorSubjects': simulatorSubjects.map((s) => s.toJson()).toList(),
      };

  static List<SimulatorSubjectScore> defaultSimulatorSubjects(String stream) {
    final isSocial = stream.toLowerCase() == 'social';
    if (isSocial) {
      return const [
        SimulatorSubjectScore(id: 'math', code: 'MAT', name: 'Mathematics', score: 0),
        SimulatorSubjectScore(id: 'economics', code: 'ECO', name: 'Economics', score: 0),
        SimulatorSubjectScore(id: 'geography', code: 'GEO', name: 'Geography', score: 0),
        SimulatorSubjectScore(id: 'history', code: 'HIS', name: 'History', score: 0),
        SimulatorSubjectScore(id: 'english', code: 'ENG', name: 'English', score: 0),
        SimulatorSubjectScore(id: 'sat', code: 'SAT', name: 'SAT', score: 0),
      ];
    }
    return const [
      SimulatorSubjectScore(id: 'math', code: 'MAT', name: 'Mathematics', score: 0),
      SimulatorSubjectScore(id: 'physics', code: 'PHY', name: 'Physics', score: 0),
      SimulatorSubjectScore(id: 'biology', code: 'BIO', name: 'Biology', score: 0),
      SimulatorSubjectScore(id: 'chemistry', code: 'CHE', name: 'Chemistry', score: 0),
      SimulatorSubjectScore(id: 'english', code: 'ENG', name: 'English', score: 0),
      SimulatorSubjectScore(id: 'sat', code: 'SAT', name: 'SAT', score: 0),
    ];
  }

  /// Generates a real-calendar zero/local-progress baseline before network sync completes.
  factory ProgressAnalyticsData.emptyBaseline({
    String stream = 'natural',
    int dailyGoalMinutes = 60,
    int completedUnitsCount = 0,
    int totalUnitsFallback = 237,
    int todayCompletedMinutes = 0,
    DateTime? anchorDate,
  }) {
    final now = anchorDate ?? DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const weekdayLetters = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    String fmtKey(DateTime dt) =>
        '${dt.year.toString().padLeft(4, '0')}-'
        '${dt.month.toString().padLeft(2, '0')}-'
        '${dt.day.toString().padLeft(2, '0')}';

    String fmtReadable(DateTime dt, {bool isToday = false}) {
      final m = months[dt.month - 1];
      final d = dt.day.toString().padLeft(2, '0');
      final w = isToday ? 'Today' : weekdays[dt.weekday - 1];
      return '$m $d • $w';
    }

    final goalMins = dailyGoalMinutes > 0 ? dailyGoalMinutes : 60;
    final clampedTodayMins = todayCompletedMinutes < 0 ? 0 : todayCompletedMinutes;
    final todayHours = (clampedTodayMins / 60 * 10).round() / 10;

    int computeLevel(int mins) {
      if (mins <= 0) return 0;
      if (mins >= goalMins && mins >= 90) return 4;
      if (mins >= (goalMins * 0.75).round() && mins >= 60) return 3;
      if (mins >= 30) return 2;
      return 1;
    }

    final heatmapDays = <HeatmapDay>[];
    for (int offset = 27; offset >= 0; offset--) {
      final dt = today.subtract(Duration(days: offset));
      final isToday = offset == 0;
      final mins = isToday ? clampedTodayMins : 0;
      heatmapDays.add(
        HeatmapDay(
          dateKey: fmtKey(dt),
          date: fmtReadable(dt, isToday: isToday),
          weekdayShort: weekdayLetters[dt.weekday - 1],
          hours: (mins / 60 * 10).round() / 10,
          minutes: mins,
          qs: 0,
          acc: 0,
          level: computeLevel(mins),
        ),
      );
    }

    final sevenPoints = <TimeframePoint>[];
    for (int offset = 6; offset >= 0; offset--) {
      final dt = today.subtract(Duration(days: offset));
      final isToday = offset == 0;
      final mins = isToday ? clampedTodayMins : 0;
      sevenPoints.add(
        TimeframePoint(
          dateKey: fmtKey(dt),
          short: isToday ? 'Today' : weekdays[dt.weekday - 1],
          label: fmtReadable(dt, isToday: isToday),
          hours: (mins / 60 * 10).round() / 10,
          minutes: mins,
          qs: 0,
          acc: 0,
        ),
      );
    }

    final thirtyStart = today.subtract(const Duration(days: 29));
    const bucketSizes = [4, 4, 4, 4, 5, 4, 5];
    final thirtyPoints = <TimeframePoint>[];
    var cursor = thirtyStart;
    for (int i = 0; i < bucketSizes.length; i++) {
      final len = bucketSizes[i];
      final bEnd = cursor.add(Duration(days: len - 1));
      final isLast = i == bucketSizes.length - 1;
      final mins = isLast ? clampedTodayMins : 0;
      thirtyPoints.add(
        TimeframePoint(
          dateKey: fmtKey(bEnd),
          short: isLast ? 'Now' : 'P${i + 1}',
          label:
              '${months[cursor.month - 1]} ${cursor.day.toString().padLeft(2, '0')} – '
              '${months[bEnd.month - 1]} ${bEnd.day.toString().padLeft(2, '0')}',
          hours: ((mins / len / 60) * 10).round() / 10,
          minutes: mins,
          qs: 0,
          acc: 0,
        ),
      );
      cursor = bEnd.add(const Duration(days: 1));
    }

    final termPoints = <TimeframePoint>[];
    for (int mOffset = 6; mOffset >= 0; mOffset--) {
      final mStart = DateTime(today.year, today.month - mOffset, 1);
      final isLast = mOffset == 0;
      final mins = isLast ? clampedTodayMins : 0;
      final daysInSlice = isLast
          ? today.day
          : DateTime(mStart.year, mStart.month + 1, 0).day;
      termPoints.add(
        TimeframePoint(
          dateKey: fmtKey(isLast ? today : DateTime(mStart.year, mStart.month + 1, 0)),
          short: months[mStart.month - 1],
          label: '${months[mStart.month - 1]} ${mStart.year}',
          hours: ((mins / daysInSlice / 60) * 10).round() / 10,
          minutes: mins,
          qs: 0,
          acc: 0,
        ),
      );
    }

    final coveragePct = totalUnitsFallback > 0
        ? ((completedUnitsCount / totalUnitsFallback) * 100).round().clamp(0, 100)
        : 0;
    final activeDays = clampedTodayMins > 0 ? 1 : 0;
    final consistency7d = ((activeDays / 7) * 100).round().clamp(0, 100);
    final consistency30d = ((activeDays / 30) * 100).round().clamp(0, 100);
    final consistencyTerm = ((activeDays / 28) * 100).round().clamp(0, 100);
    final readiness7d = (0.4 * coveragePct + 0.2 * consistency7d).round();
    final readiness30d = (0.4 * coveragePct + 0.2 * consistency30d).round();
    final readinessTerm = (0.4 * coveragePct + 0.2 * consistencyTerm).round();

    final hasActivity = completedUnitsCount > 0 || clampedTodayMins > 0;
    final subcopy = hasActivity
        ? 'Complete units & assessments to build your live EUEE projection.'
        : 'Start a unit or assessment to track your live EUEE readiness.';

    TimeframeData buildWindow({
      required int readinessPct,
      required int consistencyPct,
      required int windowDays,
      required List<TimeframePoint> pts,
    }) {
      return TimeframeData(
        readinessPct: readinessPct,
        projectedScore: 0,
        percentile: 'Baseline',
        delta: '+0.0%',
        subcopy: subcopy,
        coveragePct: coveragePct,
        accuracyPct: 0,
        consistencyPct: consistencyPct,
        completedUnits: completedUnitsCount,
        totalUnits: totalUnitsFallback,
        assessmentsCount: 0,
        dailyGoalMinutes: goalMins,
        activeDays: activeDays,
        windowDays: windowDays,
        footerHours: '${todayHours.toStringAsFixed(1)} hrs',
        footerAcc: '0.0%',
        footerQs: '0 Qs',
        points: pts,
      );
    }

    return ProgressAnalyticsData(
      stream: stream.toLowerCase(),
      dailyGoalMinutes: goalMins,
      currentStreak: clampedTodayMins > 0 ? 1 : 0,
      longestStreak: clampedTodayMins > 0 ? 1 : 0,
      timeframes: {
        ProgressTimeframe.sevenDays: buildWindow(
          readinessPct: readiness7d,
          consistencyPct: consistency7d,
          windowDays: 7,
          pts: sevenPoints,
        ),
        ProgressTimeframe.thirtyDays: buildWindow(
          readinessPct: readiness30d,
          consistencyPct: consistency30d,
          windowDays: 30,
          pts: thirtyPoints,
        ),
        ProgressTimeframe.allTerm: buildWindow(
          readinessPct: readinessTerm,
          consistencyPct: consistencyTerm,
          windowDays: 28,
          pts: termPoints,
        ),
      },
      heatmapDays: heatmapDays,
      simulatorSubjects: defaultSimulatorSubjects(stream),
    );
  }
}

/// Live pillar explanation helper
abstract class ProgressData {
  static String getPillarExplanation(ReadinessPillarType pillar, TimeframeData data) {
    switch (pillar) {
      case ReadinessPillarType.coverage:
        return 'Syllabus Coverage (${data.coveragePct}%): ${data.completedUnits} of ${data.totalUnits} stream units completed with study notes & checks.';
      case ReadinessPillarType.accuracy:
        if (data.assessmentsCount <= 0) {
          return 'Mock Accuracy (0%): Complete unit assessments to record live quiz accuracy.';
        }
        return 'Mock Accuracy (${data.accuracyPct}%): Weighted average across ${data.assessmentsCount} completed assessments in this window.';
      case ReadinessPillarType.consistency:
        final goalText = data.dailyGoalMinutes > 0
            ? '${data.dailyGoalMinutes}m daily study goal'
            : 'daily study activity';
        return 'Consistency (${data.consistencyPct}%): Active ${data.activeDays} of ${data.windowDays} days tracking toward your $goalText.';
    }
  }
}
