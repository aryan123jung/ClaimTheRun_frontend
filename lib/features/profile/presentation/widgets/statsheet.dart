// import 'package:clain_the_run/features/profile/presentation/widgets/profilestattile.dart';
// import 'package:flutter/material.dart';

// /// Shows a modal bottom sheet listing every stat, used when the "My
// /// Stats" section is collapsed to a preview of 3. Each stat gets its
// /// own tinted, color-coded card themed around its icon color.
// Future<void> showAllStatsSheet(
//   BuildContext context, {
//   required List<ProfileStatModel> stats,
// }) {
//   return showModalBottomSheet(
//     context: context,
//     isScrollControlled: true,
//     backgroundColor: Colors.white,
//     shape: const RoundedRectangleBorder(
//       borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
//     ),
//     builder: (context) {
//       final mediaQuery = MediaQuery.of(context);

//       return SafeArea(
//         top: false,
//         child: ConstrainedBox(
//           constraints: BoxConstraints(maxHeight: mediaQuery.size.height * 0.75),
//           child: SingleChildScrollView(
//             padding: EdgeInsets.fromLTRB(
//               20,
//               12,
//               20,
//               20 + mediaQuery.viewInsets.bottom,
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Center(
//                   child: Container(
//                     width: 40,
//                     height: 4,
//                     margin: const EdgeInsets.only(bottom: 18),
//                     decoration: BoxDecoration(
//                       color: const Color(0xFFD8D8D5),
//                       borderRadius: BorderRadius.circular(2),
//                     ),
//                   ),
//                 ),
//                 Row(
//                   crossAxisAlignment: CrossAxisAlignment.end,
//                   children: [
//                     const Text(
//                       'All stats',
//                       style: TextStyle(
//                         fontSize: 22,
//                         fontWeight: FontWeight.w800,
//                         color: Color(0xFF111111),
//                         letterSpacing: -0.3,
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     Padding(
//                       padding: const EdgeInsets.only(bottom: 4),
//                       child: Text(
//                         'Every mile, tracked',
//                         style: TextStyle(
//                           fontSize: 12,
//                           fontWeight: FontWeight.w500,
//                           color: Colors.grey.shade500,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 18),
//                 GridView.builder(
//                   shrinkWrap: true,
//                   physics: const NeverScrollableScrollPhysics(),
//                   itemCount: stats.length,
//                   gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
//                     maxCrossAxisExtent: 190,
//                     mainAxisExtent: 148,
//                     mainAxisSpacing: 14,
//                     crossAxisSpacing: 14,
//                   ),
//                   itemBuilder: (context, index) {
//                     return _StatGridCell(stat: stats[index]);
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ),
//       );
//     },
//   );
// }

// class _StatGridCell extends StatelessWidget {
//   const _StatGridCell({required this.stat});

//   final ProfileStatModel stat;

//   @override
//   Widget build(BuildContext context) {
//     final color = stat.iconColor;

//     return Container(
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(22),
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             color.withValues(alpha: 0.14),
//             color.withValues(alpha: 0.03),
//           ],
//         ),
//         border: Border.all(color: color.withValues(alpha: 0.18)),
//         boxShadow: [
//           BoxShadow(
//             color: color.withValues(alpha: 0.12),
//             blurRadius: 16,
//             offset: const Offset(0, 6),
//           ),
//         ],
//       ),
//       child: Stack(
//         children: [
//           // Soft decorative glow tucked in the corner for extra depth.
//           Positioned(
//             right: -18,
//             top: -18,
//             child: Container(
//               width: 70,
//               height: 70,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: color.withValues(alpha: 0.10),
//               ),
//             ),
//           ),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Container(
//                 width: 38,
//                 height: 38,
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(12),
//                   boxShadow: [
//                     BoxShadow(
//                       color: color.withValues(alpha: 0.25),
//                       blurRadius: 10,
//                       offset: const Offset(0, 3),
//                     ),
//                   ],
//                 ),
//                 child: Icon(stat.icon, size: 20, color: color),
//               ),
//               const SizedBox(height: 10),
//               FittedBox(
//                 fit: BoxFit.scaleDown,
//                 alignment: Alignment.centerLeft,
//                 child: Text(
//                   stat.value,
//                   maxLines: 1,
//                   style: const TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.w800,
//                     color: Color(0xFF111111),
//                     letterSpacing: -0.4,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 3),
//               Text(
//                 stat.label,
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//                 style: TextStyle(
//                   fontSize: 12,
//                   fontWeight: FontWeight.w600,
//                   color: color.withValues(alpha: 0.85),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:clain_the_run/features/profile/presentation/widgets/profilestattile.dart';
import 'package:flutter/material.dart';

/// Shows a modal bottom sheet listing every stat, used when the "My
/// Stats" section is collapsed to a preview of 3. Each stat gets its
/// own tinted, color-coded card themed around its icon color.
Future<void> showAllStatsSheet(
  BuildContext context, {
  required List<ProfileStatModel> stats,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: isDark ? const Color(0xFF111C26) : Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (context) {
      final mediaQuery = MediaQuery.of(context);

      return SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: mediaQuery.size.height * 0.75),
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              20,
              12,
              20,
              20 + mediaQuery.viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 18),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF233241)
                          : const Color(0xFFD8D8D5),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'All stats',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : const Color(0xFF111111),
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        'Every mile, tracked',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? const Color(0xFF9BA8B4)
                              : Colors.grey.shade500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: stats.length,
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 190,
                    mainAxisExtent: 148,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                  ),
                  itemBuilder: (context, index) {
                    return _StatGridCell(stat: stats[index]);
                  },
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class _StatGridCell extends StatelessWidget {
  const _StatGridCell({required this.stat});

  final ProfileStatModel stat;

  @override
  Widget build(BuildContext context) {
    final color = stat.iconColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.14),
            color.withValues(alpha: 0.03),
          ],
        ),
        border: Border.all(color: color.withValues(alpha: 0.18)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF16222E) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(stat.icon, size: 20, color: color),
          ),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              stat.value,
              maxLines: 1,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF111111),
                letterSpacing: -0.4,
              ),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            stat.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}
