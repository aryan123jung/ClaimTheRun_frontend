// import 'package:flutter/material.dart';

// enum _LeaderboardAudience { global, friends }

// enum _LeaderboardMode { solo, group }

// class LeaderboardScreen extends StatefulWidget {
//   const LeaderboardScreen({super.key});

//   @override
//   State<LeaderboardScreen> createState() => _LeaderboardScreenState();
// }

// class _LeaderboardScreenState extends State<LeaderboardScreen> {
//   _LeaderboardAudience _selectedAudience = _LeaderboardAudience.global;
//   _LeaderboardMode _selectedMode = _LeaderboardMode.solo;

//   static const List<_LeaderboardEntry> _entries = [
//     _LeaderboardEntry(
//       rank: 1,
//       name: 'Ram Khadka',
//       distance: '2000 km',
//       time: '15:23:43',
//       avatarAsset: 'assets/images/asv.png',
//       fallbackColor: Color(0xFFE1ECF7),
//     ),
//     _LeaderboardEntry(
//       rank: 2,
//       name: 'Shyam Karki',
//       distance: '2000 km',
//       time: '15:23:43',
//       avatarAsset: 'assets/images/dszfxgchvjbknlm.png',
//       fallbackColor: Color(0xFFEBD7B7),
//     ),
//     _LeaderboardEntry(
//       rank: 3,
//       name: 'Oliver Shrestha',
//       distance: '2000 km',
//       time: '15:23:43',
//       avatarAsset: 'assets/images/dszfxgchvjbknlm_1.png',
//       fallbackColor: Color(0xFFD8EAD9),
//     ),
//     _LeaderboardEntry(
//       rank: 4,
//       name: 'Kaji Pandey',
//       distance: '2000 km',
//       time: '15:23:43',
//       fallbackColor: Color(0xFF536A7A),
//     ),
//     _LeaderboardEntry(
//       rank: 5,
//       name: 'Hari Bahadur',
//       distance: '2000 km',
//       time: '15:23:43',
//       fallbackColor: Color(0xFF723746),
//     ),
//     _LeaderboardEntry(
//       rank: 6,
//       name: 'Sarwogya Rana',
//       distance: '2000 km',
//       time: '15:23:43',
//       fallbackColor: Color(0xFF42505A),
//     ),
//     _LeaderboardEntry(
//       rank: 7,
//       name: 'Kiran Ghiraula',
//       distance: '2000 km',
//       time: '15:23:43',
//       fallbackColor: Color(0xFF2E3341),
//     ),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF7F7F5),
//       body: SafeArea(
//         bottom: false,
//         child: Column(
//           children: [
//             Expanded(
//               child: SingleChildScrollView(
//                 padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'Leaderboard',
//                       style: TextStyle(
//                         fontSize: 28,
//                         fontWeight: FontWeight.w800,
//                         color: Color(0xFF121212),
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     const Text(
//                       'Compete, Improve, Be the best',
//                       style: TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w500,
//                         color: Color(0xFF8F8F8F),
//                       ),
//                     ),
//                     const SizedBox(height: 28),
//                     _AudienceToggle(
//                       selectedAudience: _selectedAudience,
//                       onSelected: (audience) {
//                         setState(() {
//                           _selectedAudience = audience;
//                         });
//                       },
//                     ),
//                     const SizedBox(height: 28),
//                     Center(
//                       child: _ModeToggle(
//                         selectedMode: _selectedMode,
//                         onSelected: (mode) {
//                           setState(() {
//                             _selectedMode = mode;
//                           });
//                         },
//                       ),
//                     ),
//                     const SizedBox(height: 28),
//                     ..._entries.map(
//                       (entry) => Padding(
//                         padding: const EdgeInsets.only(bottom: 16),
//                         child: _LeaderboardCard(entry: entry),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _AudienceToggle extends StatelessWidget {
//   const _AudienceToggle({
//     required this.selectedAudience,
//     required this.onSelected,
//   });

//   final _LeaderboardAudience selectedAudience;
//   final ValueChanged<_LeaderboardAudience> onSelected;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 88,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(28),
//         border: Border.all(color: const Color(0xFF808080), width: 1.2),
//       ),
//       child: Row(
//         children: [
//           Expanded(
//             child: _AudienceOption(
//               icon: Icons.public,
//               label: 'Global',
//               selected: selectedAudience == _LeaderboardAudience.global,
//               onTap: () => onSelected(_LeaderboardAudience.global),
//             ),
//           ),
//           Container(width: 1.2, color: const Color(0xFFD4D4D4)),
//           Expanded(
//             child: _AudienceOption(
//               icon: Icons.group_outlined,
//               label: 'Friends',
//               selected: selectedAudience == _LeaderboardAudience.friends,
//               onTap: () => onSelected(_LeaderboardAudience.friends),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _AudienceOption extends StatelessWidget {
//   const _AudienceOption({
//     required this.icon,
//     required this.label,
//     required this.selected,
//     required this.onTap,
//   });

//   final IconData icon;
//   final String label;
//   final bool selected;
//   final VoidCallback onTap;

//   @override
//   Widget build(BuildContext context) {
//     final color = selected ? const Color(0xFF21B455) : const Color(0xFFA9AEAC);

//     return Material(
//       color: Colors.transparent,
//       child: InkWell(
//         borderRadius: BorderRadius.circular(28),
//         onTap: onTap,
//         child: Center(
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(icon, size: 38, color: color),
//               const SizedBox(width: 12),
//               Text(
//                 label,
//                 style: TextStyle(
//                   fontSize: 28,
//                   fontWeight: FontWeight.w700,
//                   color: color,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _ModeToggle extends StatelessWidget {
//   const _ModeToggle({required this.selectedMode, required this.onSelected});

//   final _LeaderboardMode selectedMode;
//   final ValueChanged<_LeaderboardMode> onSelected;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 314,
//       height: 58,
//       padding: const EdgeInsets.all(4),
//       decoration: BoxDecoration(
//         color: const Color(0xFFE9E9E9),
//         borderRadius: BorderRadius.circular(30),
//       ),
//       child: Row(
//         children: [
//           Expanded(
//             child: _ModeOption(
//               label: 'Solo',
//               active: selectedMode == _LeaderboardMode.solo,
//               onTap: () => onSelected(_LeaderboardMode.solo),
//             ),
//           ),
//           Expanded(
//             child: _ModeOption(
//               label: 'Group',
//               active: selectedMode == _LeaderboardMode.group,
//               onTap: () => onSelected(_LeaderboardMode.group),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _ModeOption extends StatelessWidget {
//   const _ModeOption({
//     required this.label,
//     required this.active,
//     required this.onTap,
//   });

//   final String label;
//   final bool active;
//   final VoidCallback onTap;

//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       color: Colors.transparent,
//       child: InkWell(
//         borderRadius: BorderRadius.circular(26),
//         onTap: onTap,
//         child: AnimatedContainer(
//           duration: const Duration(milliseconds: 180),
//           decoration: BoxDecoration(
//             color: active ? const Color(0xFF28C55B) : Colors.transparent,
//             borderRadius: BorderRadius.circular(26),
//             boxShadow: active
//                 ? const [
//                     BoxShadow(
//                       color: Color(0x3328C55B),
//                       blurRadius: 16,
//                       offset: Offset(0, 8),
//                     ),
//                   ]
//                 : null,
//           ),
//           alignment: Alignment.center,
//           child: Text(
//             label,
//             style: TextStyle(
//               fontSize: 24,
//               fontWeight: FontWeight.w700,
//               color: active ? Colors.white : const Color(0xFF8F9390),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _LeaderboardCard extends StatelessWidget {
//   const _LeaderboardCard({required this.entry});

//   final _LeaderboardEntry entry;

//   @override
//   Widget build(BuildContext context) {
//     final bool isPodium = entry.rank <= 3;

//     return Container(
//       height: 132,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: const Color(0xFFD0D0D0), width: 1.2),
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 122,
//             decoration: BoxDecoration(
//               gradient: isPodium
//                   ? LinearGradient(
//                       begin: Alignment.centerLeft,
//                       end: Alignment.centerRight,
//                       colors: _podiumColors(entry.rank),
//                     )
//                   : null,
//               borderRadius: const BorderRadius.only(
//                 topLeft: Radius.circular(20),
//                 bottomLeft: Radius.circular(20),
//               ),
//             ),
//             alignment: Alignment.center,
//             child: isPodium
//                 ? _PodiumBadge(rank: entry.rank)
//                 : Text(
//                     '${entry.rank}',
//                     style: const TextStyle(
//                       fontSize: 36,
//                       fontWeight: FontWeight.w700,
//                       color: Color(0xFF454545),
//                     ),
//                   ),
//           ),
//           Expanded(
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: Row(
//                 children: [
//                   _LeaderboardAvatar(entry: entry),
//                   const SizedBox(width: 16),
//                   Expanded(
//                     child: Text(
//                       entry.name,
//                       style: const TextStyle(
//                         fontSize: 26,
//                         fontWeight: FontWeight.w700,
//                         color: Color(0xFF4A4A4A),
//                       ),
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     crossAxisAlignment: CrossAxisAlignment.end,
//                     children: [
//                       Text(
//                         entry.distance,
//                         style: const TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.w600,
//                           color: Color(0xFF4B4B4B),
//                         ),
//                       ),
//                       const SizedBox(height: 6),
//                       Text(
//                         entry.time,
//                         style: const TextStyle(
//                           fontSize: 14,
//                           fontWeight: FontWeight.w700,
//                           color: Color(0xFF4B4B4B),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   List<Color> _podiumColors(int rank) {
//     switch (rank) {
//       case 1:
//         return const [Color(0xFFF6C548), Color(0xFFFFF7E3)];
//       case 2:
//         return const [Color(0xFFAFC7E8), Color(0xFFF6F8FC)];
//       default:
//         return const [Color(0xFFF5A36D), Color(0xFFFFF0E8)];
//     }
//   }
// }

// class _LeaderboardAvatar extends StatelessWidget {
//   const _LeaderboardAvatar({required this.entry});

//   final _LeaderboardEntry entry;

//   @override
//   Widget build(BuildContext context) {
//     final String initials = entry.name
//         .split(' ')
//         .where((part) => part.isNotEmpty)
//         .take(2)
//         .map((part) => part[0])
//         .join();

//     return Container(
//       width: 66,
//       height: 66,
//       decoration: BoxDecoration(
//         shape: BoxShape.circle,
//         border: Border.all(color: const Color(0xFF5CB748), width: 1.6),
//       ),
//       child: ClipOval(
//         child: entry.avatarAsset != null
//             ? Image.asset(
//                 entry.avatarAsset!,
//                 fit: BoxFit.cover,
//                 errorBuilder: (_, _, _) => _AvatarFallback(
//                   backgroundColor: entry.fallbackColor,
//                   initials: initials,
//                 ),
//               )
//             : _AvatarFallback(
//                 backgroundColor: entry.fallbackColor,
//                 initials: initials,
//               ),
//       ),
//     );
//   }
// }

// class _AvatarFallback extends StatelessWidget {
//   const _AvatarFallback({
//     required this.backgroundColor,
//     required this.initials,
//   });

//   final Color backgroundColor;
//   final String initials;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: backgroundColor,
//       alignment: Alignment.center,
//       child: Text(
//         initials,
//         style: const TextStyle(
//           fontSize: 22,
//           fontWeight: FontWeight.w700,
//           color: Colors.white,
//         ),
//       ),
//     );
//   }
// }

// class _PodiumBadge extends StatelessWidget {
//   const _PodiumBadge({required this.rank});

//   final int rank;

//   @override
//   Widget build(BuildContext context) {
//     final Color medalColor = switch (rank) {
//       1 => const Color(0xFFFFCC39),
//       2 => const Color(0xFFD8D8D8),
//       _ => const Color(0xFFFF9C3A),
//     };

//     final Color medalBorder = switch (rank) {
//       1 => const Color(0xFFD9A423),
//       2 => const Color(0xFFADADAD),
//       _ => const Color(0xFFD57B22),
//     };

//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         const Icon(Icons.workspace_premium, size: 44, color: Color(0xFF2890E0)),
//         Transform.translate(
//           offset: const Offset(0, -6),
//           child: Container(
//             width: 46,
//             height: 46,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               color: medalColor,
//               border: Border.all(color: medalBorder, width: 1.5),
//             ),
//             alignment: Alignment.center,
//             child: Text(
//               '$rank',
//               style: TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.w800,
//                 color: rank == 2
//                     ? const Color(0xFF686868)
//                     : const Color(0xFFF18816),
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

// class _LeaderboardEntry {
//   const _LeaderboardEntry({
//     required this.rank,
//     required this.name,
//     required this.distance,
//     required this.time,
//     required this.fallbackColor,
//     this.avatarAsset,
//   });

//   final int rank;
//   final String name;
//   final String distance;
//   final String time;
//   final String? avatarAsset;
//   final Color fallbackColor;
// }

import 'package:clain_the_run/features/leaderboard/presentation/widgets/card.dart';
import 'package:flutter/material.dart';

enum LeaderboardScope { global, friends }

enum LeaderboardMode { solo, group }

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  static const _brandGreen = Color(0xFF72B63E);
  static const _activeTextGreen = Color(0xFF3B6D11);

  LeaderboardScope _scope = LeaderboardScope.global;
  LeaderboardMode _mode = LeaderboardMode.solo;

  // Placeholder data — replace with real leaderboard data from your backend.
  final List<LeaderboardEntry> _entries = const [
    LeaderboardEntry(
      rank: 1,
      name: 'Ram Khadka',
      avatarUrl: 'https://i.pravatar.cc/150?img=12',
      distanceKm: 2000,
      time: '15:23:43',
    ),
    LeaderboardEntry(
      rank: 2,
      name: 'Shyam Karki',
      avatarUrl: 'https://i.pravatar.cc/150?img=13',
      distanceKm: 2000,
      time: '15:23:43',
    ),
    LeaderboardEntry(
      rank: 3,
      name: 'Oliver Shrestha',
      avatarUrl: 'https://i.pravatar.cc/150?img=14',
      distanceKm: 2000,
      time: '15:23:43',
    ),
    LeaderboardEntry(
      rank: 4,
      name: 'Kaji Pandey',
      avatarUrl: 'https://i.pravatar.cc/150?img=15',
      distanceKm: 2000,
      time: '15:23:43',
    ),
    LeaderboardEntry(
      rank: 5,
      name: 'Hari Bahadur',
      avatarUrl: 'https://i.pravatar.cc/150?img=16',
      distanceKm: 2000,
      time: '15:23:43',
    ),
    LeaderboardEntry(
      rank: 6,
      name: 'You',
      avatarUrl: 'https://i.pravatar.cc/150?img=17',
      distanceKm: 2000,
      time: '15:23:43',
      isCurrentUser: true,
    ),
    LeaderboardEntry(
      rank: 7,
      name: 'Kiran Ghiraula',
      avatarUrl: 'https://i.pravatar.cc/150?img=18',
      distanceKm: 2000,
      time: '15:23:43',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Leaderboard',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF111111),
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Compete, improve, be the best',
                    style: TextStyle(fontSize: 13, color: Color(0xFF8B8B8B)),
                  ),
                  const SizedBox(height: 14),
                  _SegmentedToggle<LeaderboardScope>(
                    height: 40,
                    value: _scope,
                    onChanged: (value) => setState(() => _scope = value),
                    options: const [
                      _SegmentOption(
                        value: LeaderboardScope.global,
                        icon: Icons.public_rounded,
                        label: 'Global',
                      ),
                      _SegmentOption(
                        value: LeaderboardScope.friends,
                        icon: Icons.people_outline_rounded,
                        label: 'Friends',
                      ),
                    ],
                    activeColor: _activeTextGreen,
                  ),
                  const SizedBox(height: 20),
                  // Solo/Group sits centered under Global/Friends rather
                  // than left-aligned, since it reads as a secondary
                  // filter for the whole list below, not tied to one side.
                  Center(
                    child: SizedBox(
                      width: 150,
                      child: _SegmentedToggle<LeaderboardMode>(
                        height: 34,
                        value: _mode,
                        onChanged: (value) => setState(() => _mode = value),
                        compact: true,
                        activeColor: Colors.white,
                        activeBackground: _brandGreen,
                        options: const [
                          _SegmentOption(
                            value: LeaderboardMode.solo,
                            label: 'Solo',
                          ),
                          _SegmentOption(
                            value: LeaderboardMode.group,
                            label: 'Group',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                itemCount: _entries.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: LeaderboardCard(entry: _entries[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SegmentOption<T> {
  const _SegmentOption({required this.value, required this.label, this.icon});

  final T value;
  final String label;
  final IconData? icon;
}

class _SegmentedToggle<T> extends StatelessWidget {
  const _SegmentedToggle({
    required this.value,
    required this.onChanged,
    required this.options,
    required this.height,
    this.activeColor = const Color(0xFF111111),
    this.activeBackground = Colors.white,
    this.compact = false,
  });

  final T value;
  final ValueChanged<T> onChanged;
  final List<_SegmentOption<T>> options;
  final double height;
  final Color activeColor;
  final Color activeBackground;
  final bool compact;

  static const _inactiveColor = Color(0xFFA7AEAA);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F1EF),
        borderRadius: BorderRadius.circular(compact ? 9 : 11),
      ),
      child: Row(
        children: [
          for (final option in options)
            Expanded(
              child: _SegmentButton(
                isActive: option.value == value,
                icon: option.icon,
                label: option.label,
                activeColor: activeColor,
                activeBackground: activeBackground,
                inactiveColor: _inactiveColor,
                compact: compact,
                onTap: () => onChanged(option.value),
              ),
            ),
        ],
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  const _SegmentButton({
    required this.isActive,
    required this.label,
    required this.activeColor,
    required this.activeBackground,
    required this.inactiveColor,
    required this.compact,
    required this.onTap,
    this.icon,
  });

  final bool isActive;
  final IconData? icon;
  final String label;
  final Color activeColor;
  final Color activeBackground;
  final Color inactiveColor;
  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? activeColor : inactiveColor;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isActive ? activeBackground : Colors.transparent,
        borderRadius: BorderRadius.circular(compact ? 7 : 9),
        boxShadow: isActive && activeBackground == Colors.white
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(compact ? 7 : 9),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: compact ? 6 : 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 14, color: color),
                  const SizedBox(width: 6),
                ],
                Text(
                  label,
                  style: TextStyle(
                    fontSize: compact ? 12 : 13,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
