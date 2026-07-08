import 'package:flutter/material.dart';

class DailyDistance {
  const DailyDistance({required this.label, required this.km});

  final String label;
  final double km;
}

class WeeklyActivityChart extends StatelessWidget {
  const WeeklyActivityChart({
    super.key,
    required this.days,
    required this.totalDistanceKm,
    required this.totalTime,
    required this.avgPace,
  });

  final List<DailyDistance> days;
  final double totalDistanceKm;
  final String totalTime;
  final String avgPace;

  // static const _brandGreen = Color(0xFF72B63E);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final maxKm = days.map((d) => d.km).reduce((a, b) => a > b ? a : b);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111C26) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(0xFF233241) : const Color(0xFFD8D8D5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.07),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 18, 8, 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (final day in days)
                      Expanded(
                        child: _DayBar(
                          day: day,
                          heightFraction: maxKm == 0 ? 0 : day.km / maxKm,
                          isHighlighted: day.km == maxKm,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            VerticalDivider(
              width: 1,
              color: isDark ? const Color(0xFF233241) : const Color(0xFFD8D8D5),
            ),

            SizedBox(
              width: 128,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 18,
                  horizontal: 14,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SummaryStat(
                      value: '${totalDistanceKm.toStringAsFixed(1)} km',
                      label: 'Distance',
                    ),
                    const SizedBox(height: 16),
                    _SummaryStat(value: totalTime, label: 'Time'),
                    const SizedBox(height: 16),
                    _SummaryStat(value: avgPace, label: 'Avg pace'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DayBar extends StatelessWidget {
  const _DayBar({
    required this.day,
    required this.heightFraction,
    required this.isHighlighted,
  });

  final DailyDistance day;
  final double heightFraction;
  final bool isHighlighted;

  static const _brandGreen = Color(0xFF72B63E);
  static const _mutedGreen = Color(0xFFA9D188);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const maxBarHeight = 120.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${day.km.toStringAsFixed(1)}\nkm',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 10,
            height: 1.2,
            fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.w400,
            color: isHighlighted
                ? (isDark ? Colors.white : const Color(0xFF111111))
                : (isDark ? const Color(0xFF9BA8B4) : const Color(0xFF6E6E6E)),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: (maxBarHeight * heightFraction).clamp(4, maxBarHeight),
          width: 10,
          decoration: BoxDecoration(
            color: isHighlighted ? _brandGreen : _mutedGreen,
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          day.label,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? const Color(0xFF9BA8B4) : const Color(0xFF6E6E6E),
          ),
        ),
      ],
    );
  }
}

class _SummaryStat extends StatelessWidget {
  const _SummaryStat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : const Color(0xFF111111),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? const Color(0xFF9BA8B4) : const Color(0xFF6E6E6E),
          ),
        ),
      ],
    );
  }
}
