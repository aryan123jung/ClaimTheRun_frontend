// import 'dart:math';

// import 'package:flutter/material.dart';
// import 'package:maplibre_gl/maplibre_gl.dart';

// enum MapRunMode { solo, group }

// class MapScreen extends StatefulWidget {
//   const MapScreen({super.key});

//   @override
//   State<MapScreen> createState() => _MapScreenState();
// }

// class _MapScreenState extends State<MapScreen> {
//   static const _mapCenter = LatLng(27.7172, 85.3240);
//   static const _brandGreen = Color(0xFF72B63E);

//   static const _mapStyle = '''
// {
//   "version": 8,
//   "sources": {
//     "osm": {
//       "type": "raster",
//       "tiles": [
//         "https://tile.openstreetmap.org/{z}/{x}/{y}.png"
//       ],
//       "tileSize": 256,
//       "attribution": "© OpenStreetMap contributors"
//     }
//   },
//   "layers": [
//     {
//       "id": "osm",
//       "type": "raster",
//       "source": "osm"
//     }
//   ]
// }
// ''';

//   MapRunMode _selectedMode = MapRunMode.solo;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Stack(
//         fit: StackFit.expand,
//         children: [
//           // Full-bleed map, fills the entire screen behind everything else.
//           MapLibreMap(
//             styleString: _mapStyle,
//             initialCameraPosition: const CameraPosition(
//               target: _mapCenter,
//               zoom: 12.8,
//             ),
//             compassEnabled: false,
//             myLocationEnabled: false,
//             rotateGesturesEnabled: false,
//             tiltGesturesEnabled: false,
//             attributionButtonMargins: const Point(-1000, -1000),
//           ),
//           const Center(child: _MapPin(color: _brandGreen)),

//           // Floating header + run type toggle, fades into the map below it.
//           Positioned(
//             top: 0,
//             left: 0,
//             right: 0,
//             child: SafeArea(
//               bottom: false,
//               child: Container(
//                 padding: const EdgeInsets.fromLTRB(18, 8, 18, 16),
//                 decoration: const BoxDecoration(
//                   gradient: LinearGradient(
//                     begin: Alignment.topCenter,
//                     end: Alignment.bottomCenter,
//                     colors: [Color(0xEBFFFFFF), Color(0x00FFFFFF)],
//                     stops: [0.6, 1.0],
//                   ),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'Map',
//                       style: TextStyle(
//                         fontSize: 22,
//                         fontWeight: FontWeight.w500,
//                         color: Color(0xFF111111),
//                       ),
//                     ),
//                     const SizedBox(height: 2),
//                     const Text(
//                       'Choose your run type and start tracking',
//                       style: TextStyle(fontSize: 13, color: Color(0xFF8B8B8B)),
//                     ),
//                     const SizedBox(height: 14),
//                     _RunTypeToggle(
//                       selectedMode: _selectedMode,
//                       onModeChanged: (mode) {
//                         setState(() {
//                           _selectedMode = mode;
//                         });
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),

//           // Recenter button, floats over the map on the right.
//           Positioned(
//             top: 150,
//             right: 16,
//             child: SafeArea(child: _RecenterButton(onPressed: () {})),
//           ),

//           // Bottom tracking card, floats over the map.
//           Positioned(
//             left: 14,
//             right: 14,
//             bottom: 18,
//             child: SafeArea(
//               top: false,
//               child: _TrackingCard(
//                 onStartPressed: () {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content: Text(
//                         'Starting ${_selectedMode.name} run tracking...',
//                       ),
//                     ),
//                   );
//                 },
//                 onTerritoriesPressed: () {},
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _RunTypeToggle extends StatelessWidget {
//   const _RunTypeToggle({
//     required this.selectedMode,
//     required this.onModeChanged,
//   });

//   final MapRunMode selectedMode;
//   final ValueChanged<MapRunMode> onModeChanged;

//   static const _activeColor = Color(0xFF3B6D11);
//   static const _inactiveColor = Color(0xFFA7AEAA);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 44,
//       padding: const EdgeInsets.all(3),
//       decoration: BoxDecoration(
//         color: const Color(0xE6F1F1EF),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Row(
//         children: [
//           Expanded(
//             child: _RunTypeOption(
//               icon: Icons.person_outline_rounded,
//               label: 'Solo',
//               isActive: selectedMode == MapRunMode.solo,
//               activeColor: _activeColor,
//               inactiveColor: _inactiveColor,
//               onTap: () => onModeChanged(MapRunMode.solo),
//             ),
//           ),
//           Expanded(
//             child: _RunTypeOption(
//               icon: Icons.groups_2_outlined,
//               label: 'Group',
//               isActive: selectedMode == MapRunMode.group,
//               activeColor: _activeColor,
//               inactiveColor: _inactiveColor,
//               onTap: () => onModeChanged(MapRunMode.group),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _RunTypeOption extends StatelessWidget {
//   const _RunTypeOption({
//     required this.icon,
//     required this.label,
//     required this.isActive,
//     required this.activeColor,
//     required this.inactiveColor,
//     required this.onTap,
//   });

//   final IconData icon;
//   final String label;
//   final bool isActive;
//   final Color activeColor;
//   final Color inactiveColor;
//   final VoidCallback onTap;

//   @override
//   Widget build(BuildContext context) {
//     final color = isActive ? activeColor : inactiveColor;

//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 200),
//       decoration: BoxDecoration(
//         color: isActive ? Colors.white : Colors.transparent,
//         borderRadius: BorderRadius.circular(9),
//         boxShadow: isActive
//             ? [
//                 BoxShadow(
//                   color: Colors.black.withValues(alpha: 0.06),
//                   blurRadius: 4,
//                   offset: const Offset(0, 1),
//                 ),
//               ]
//             : null,
//       ),
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           onTap: onTap,
//           borderRadius: BorderRadius.circular(9),
//           child: Padding(
//             padding: const EdgeInsets.symmetric(vertical: 8),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(icon, size: 16, color: color),
//                 const SizedBox(width: 6),
//                 Text(
//                   label,
//                   style: TextStyle(
//                     fontSize: 13,
//                     fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
//                     color: color,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _RecenterButton extends StatelessWidget {
//   const _RecenterButton({required this.onPressed});

//   final VoidCallback onPressed;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 38,
//       height: 38,
//       decoration: BoxDecoration(
//         color: const Color(0xD9FFFFFF),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: const Color(0xFFE7E7E4)),
//       ),
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           onTap: onPressed,
//           borderRadius: BorderRadius.circular(12),
//           child: const Icon(
//             Icons.my_location_rounded,
//             size: 17,
//             color: Color(0xFF3B6D11),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _MapPin extends StatelessWidget {
//   const _MapPin({required this.color});

//   final Color color;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 16,
//       height: 16,
//       decoration: BoxDecoration(
//         color: color,
//         shape: BoxShape.circle,
//         border: Border.all(color: Colors.white, width: 3),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.15),
//             blurRadius: 4,
//             offset: const Offset(0, 1),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _TrackingCard extends StatelessWidget {
//   const _TrackingCard({
//     required this.onStartPressed,
//     required this.onTerritoriesPressed,
//   });

//   final VoidCallback onStartPressed;
//   final VoidCallback onTerritoriesPressed;

//   static const _brandGreen = Color(0xFF72B63E);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(22),
//         border: Border.all(color: const Color(0xFFE4E4E1)),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.08),
//             blurRadius: 16,
//             offset: const Offset(0, 6),
//           ),
//         ],
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Row(
//             children: [
//               const Icon(
//                 Icons.directions_run_rounded,
//                 color: Color(0xFF67B337),
//                 size: 24,
//               ),
//               const SizedBox(width: 10),
//               const Text(
//                 'Live tracking',
//                 style: TextStyle(fontSize: 15, color: Color(0xFF1A1A1A)),
//               ),
//               const Spacer(),
//               Material(
//                 color: Colors.transparent,
//                 child: InkWell(
//                   onTap: onTerritoriesPressed,
//                   borderRadius: BorderRadius.circular(24),
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 14,
//                       vertical: 9,
//                     ),
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(24),
//                       border: Border.all(color: const Color(0xFFD7D7D7)),
//                     ),
//                     child: const Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Icon(
//                           Icons.map_outlined,
//                           size: 18,
//                           color: Color(0xFF8F9694),
//                         ),
//                         SizedBox(width: 8),
//                         Text(
//                           'Territories',
//                           style: TextStyle(
//                             fontSize: 14,
//                             color: Color(0xFF1A1A1A),
//                           ),
//                         ),
//                         SizedBox(width: 4),
//                         Icon(
//                           Icons.chevron_right_rounded,
//                           size: 18,
//                           color: Color(0xFF6E6E6E),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 20),
//           RichText(
//             text: const TextSpan(
//               style: TextStyle(
//                 color: Color(0xFF111111),
//                 fontWeight: FontWeight.w700,
//               ),
//               children: [
//                 TextSpan(text: '0.00', style: TextStyle(fontSize: 44)),
//                 TextSpan(
//                   text: ' km',
//                   style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 2),
//           const Text(
//             'Distance',
//             style: TextStyle(fontSize: 13, color: Color(0xFF9A9A9A)),
//           ),
//           const SizedBox(height: 18),
//           SizedBox(
//             width: double.infinity,
//             height: 52,
//             child: ElevatedButton.icon(
//               onPressed: onStartPressed,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: _brandGreen,
//                 foregroundColor: Colors.white,
//                 elevation: 0,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(26),
//                 ),
//                 textStyle: const TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               icon: const Icon(Icons.play_arrow_rounded, size: 20),
//               label: const Text('Start run'),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// import 'dart:math';

// import 'package:flutter/material.dart';
// import 'package:maplibre_gl/maplibre_gl.dart';

// enum MapRunMode { solo, group }

// class MapScreen extends StatefulWidget {
//   const MapScreen({super.key});

//   @override
//   State<MapScreen> createState() => _MapScreenState();
// }

// class _MapScreenState extends State<MapScreen> {
//   static const _mapCenter = LatLng(27.7172, 85.3240);
//   static const _brandGreen = Color(0xFF72B63E);

//   static const _mapStyle = '''
// {
//   "version": 8,
//   "sources": {
//     "osm": {
//       "type": "raster",
//       "tiles": [
//         "https://tile.openstreetmap.org/{z}/{x}/{y}.png"
//       ],
//       "tileSize": 256,
//       "attribution": "© OpenStreetMap contributors"
//     }
//   },
//   "layers": [
//     {
//       "id": "osm",
//       "type": "raster",
//       "source": "osm"
//     }
//   ]
// }
// ''';

//   MapRunMode _selectedMode = MapRunMode.solo;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Stack(
//         fit: StackFit.expand,
//         children: [
//           // Full-bleed map, fills the entire screen behind everything else.
//           MapLibreMap(
//             styleString: _mapStyle,
//             initialCameraPosition: const CameraPosition(
//               target: _mapCenter,
//               zoom: 12.8,
//             ),
//             compassEnabled: false,
//             myLocationEnabled: false,
//             rotateGesturesEnabled: false,
//             tiltGesturesEnabled: false,
//             attributionButtonMargins: const Point(-1000, -1000),
//           ),
//           const Center(child: _MapPin(color: _brandGreen)),

//           // Floating header + run type toggle, fades into the map below it.
//           Positioned(
//             top: 0,
//             left: 0,
//             right: 0,
//             child: SafeArea(
//               bottom: false,
//               child: Container(
//                 padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
//                 decoration: const BoxDecoration(
//                   gradient: LinearGradient(
//                     begin: Alignment.topCenter,
//                     end: Alignment.bottomCenter,
//                     colors: [
//                       Color(0xFFFFFFFF),
//                       Color(0xF2FFFFFF),
//                       Color(0xB3FFFFFF),
//                       Color(0x00FFFFFF),
//                     ],
//                     stops: [0.0, 0.45, 0.75, 1.0],
//                   ),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'Map',
//                       style: TextStyle(
//                         fontSize: 22,
//                         fontWeight: FontWeight.w500,
//                         color: Color(0xFF111111),
//                       ),
//                     ),
//                     const SizedBox(height: 2),
//                     const Text(
//                       'Choose your run type and start tracking',
//                       style: TextStyle(fontSize: 13, color: Color(0xFF8B8B8B)),
//                     ),
//                     const SizedBox(height: 14),
//                     _RunTypeToggle(
//                       selectedMode: _selectedMode,
//                       onModeChanged: (mode) {
//                         setState(() {
//                           _selectedMode = mode;
//                         });
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),

//           // Recenter button, floats over the map on the right.
//           Positioned(
//             top: 150,
//             right: 16,
//             child: SafeArea(child: _RecenterButton(onPressed: () {})),
//           ),

//           // Bottom tracking card, floats over the map.
//           Positioned(
//             left: 14,
//             right: 14,
//             bottom: 18,
//             child: SafeArea(
//               top: false,
//               child: _TrackingCard(
//                 onStartPressed: () {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content: Text(
//                         'Starting ${_selectedMode.name} run tracking...',
//                       ),
//                     ),
//                   );
//                 },
//                 onTerritoriesPressed: () {},
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _RunTypeToggle extends StatelessWidget {
//   const _RunTypeToggle({
//     required this.selectedMode,
//     required this.onModeChanged,
//   });

//   final MapRunMode selectedMode;
//   final ValueChanged<MapRunMode> onModeChanged;

//   static const _activeColor = Color(0xFF3B6D11);
//   static const _inactiveColor = Color(0xFFA7AEAA);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 44,
//       padding: const EdgeInsets.all(3),
//       decoration: BoxDecoration(
//         color: const Color(0xE6F1F1EF),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Row(
//         children: [
//           Expanded(
//             child: _RunTypeOption(
//               icon: Icons.person_outline_rounded,
//               label: 'Solo',
//               isActive: selectedMode == MapRunMode.solo,
//               activeColor: _activeColor,
//               inactiveColor: _inactiveColor,
//               onTap: () => onModeChanged(MapRunMode.solo),
//             ),
//           ),
//           Expanded(
//             child: _RunTypeOption(
//               icon: Icons.groups_2_outlined,
//               label: 'Group',
//               isActive: selectedMode == MapRunMode.group,
//               activeColor: _activeColor,
//               inactiveColor: _inactiveColor,
//               onTap: () => onModeChanged(MapRunMode.group),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _RunTypeOption extends StatelessWidget {
//   const _RunTypeOption({
//     required this.icon,
//     required this.label,
//     required this.isActive,
//     required this.activeColor,
//     required this.inactiveColor,
//     required this.onTap,
//   });

//   final IconData icon;
//   final String label;
//   final bool isActive;
//   final Color activeColor;
//   final Color inactiveColor;
//   final VoidCallback onTap;

//   @override
//   Widget build(BuildContext context) {
//     final color = isActive ? activeColor : inactiveColor;

//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 200),
//       decoration: BoxDecoration(
//         color: isActive ? Colors.white : Colors.transparent,
//         borderRadius: BorderRadius.circular(9),
//         boxShadow: isActive
//             ? [
//                 BoxShadow(
//                   color: Colors.black.withValues(alpha: 0.06),
//                   blurRadius: 4,
//                   offset: const Offset(0, 1),
//                 ),
//               ]
//             : null,
//       ),
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           onTap: onTap,
//           borderRadius: BorderRadius.circular(9),
//           child: Padding(
//             padding: const EdgeInsets.symmetric(vertical: 8),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(icon, size: 16, color: color),
//                 const SizedBox(width: 6),
//                 Text(
//                   label,
//                   style: TextStyle(
//                     fontSize: 13,
//                     fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
//                     color: color,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _RecenterButton extends StatelessWidget {
//   const _RecenterButton({required this.onPressed});

//   final VoidCallback onPressed;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 38,
//       height: 38,
//       decoration: BoxDecoration(
//         color: const Color(0xD9FFFFFF),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: const Color(0xFFE7E7E4)),
//       ),
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           onTap: onPressed,
//           borderRadius: BorderRadius.circular(12),
//           child: const Icon(
//             Icons.my_location_rounded,
//             size: 17,
//             color: Color(0xFF3B6D11),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _MapPin extends StatelessWidget {
//   const _MapPin({required this.color});

//   final Color color;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 16,
//       height: 16,
//       decoration: BoxDecoration(
//         color: color,
//         shape: BoxShape.circle,
//         border: Border.all(color: Colors.white, width: 3),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.15),
//             blurRadius: 4,
//             offset: const Offset(0, 1),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _TrackingCard extends StatelessWidget {
//   const _TrackingCard({
//     required this.onStartPressed,
//     required this.onTerritoriesPressed,
//   });

//   final VoidCallback onStartPressed;
//   final VoidCallback onTerritoriesPressed;

//   static const _brandGreen = Color(0xFF72B63E);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(22),
//         border: Border.all(color: const Color(0xFFE4E4E1)),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.08),
//             blurRadius: 16,
//             offset: const Offset(0, 6),
//           ),
//         ],
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Row(
//             children: [
//               const Icon(
//                 Icons.directions_run_rounded,
//                 color: Color(0xFF67B337),
//                 size: 24,
//               ),
//               const SizedBox(width: 10),
//               const Text(
//                 'Live tracking',
//                 style: TextStyle(fontSize: 15, color: Color(0xFF1A1A1A)),
//               ),
//               const Spacer(),
//               Material(
//                 color: Colors.transparent,
//                 child: InkWell(
//                   onTap: onTerritoriesPressed,
//                   borderRadius: BorderRadius.circular(24),
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 14,
//                       vertical: 9,
//                     ),
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(24),
//                       border: Border.all(color: const Color(0xFFD7D7D7)),
//                     ),
//                     child: const Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Icon(
//                           Icons.map_outlined,
//                           size: 18,
//                           color: Color(0xFF8F9694),
//                         ),
//                         SizedBox(width: 8),
//                         Text(
//                           'Territories',
//                           style: TextStyle(
//                             fontSize: 14,
//                             color: Color(0xFF1A1A1A),
//                           ),
//                         ),
//                         SizedBox(width: 4),
//                         Icon(
//                           Icons.chevron_right_rounded,
//                           size: 18,
//                           color: Color(0xFF6E6E6E),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 20),
//           RichText(
//             text: const TextSpan(
//               style: TextStyle(
//                 color: Color(0xFF111111),
//                 fontWeight: FontWeight.w700,
//               ),
//               children: [
//                 TextSpan(text: '0.00', style: TextStyle(fontSize: 44)),
//                 TextSpan(
//                   text: ' km',
//                   style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 2),
//           const Text(
//             'Distance',
//             style: TextStyle(fontSize: 13, color: Color(0xFF9A9A9A)),
//           ),
//           const SizedBox(height: 18),
//           SizedBox(
//             width: double.infinity,
//             height: 52,
//             child: ElevatedButton.icon(
//               onPressed: onStartPressed,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: _brandGreen,
//                 foregroundColor: Colors.white,
//                 elevation: 0,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(26),
//                 ),
//                 textStyle: const TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               icon: const Icon(Icons.play_arrow_rounded, size: 20),
//               label: const Text('Start run'),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'dart:async';
import 'dart:math';

import 'package:clain_the_run/features/leaderboard/presentation/pages/leaderboard.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:permission_handler/permission_handler.dart';

enum MapRunMode { solo, group }

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const _mapCenter = LatLng(27.7172, 85.3240);

  static const _mapStyle = '''
{
  "version": 8,
  "sources": {
    "osm": {
      "type": "raster",
      "tiles": [
        "https://tile.openstreetmap.org/{z}/{x}/{y}.png"
      ],
      "tileSize": 256,
      "attribution": "© OpenStreetMap contributors"
    }
  },
  "layers": [
    {
      "id": "osm",
      "type": "raster",
      "source": "osm"
    }
  ]
}
''';

  MapRunMode _selectedMode = MapRunMode.solo;
  bool _isRunning = false;
  bool _hasLocationPermission = false;
  bool _isMapStyleReady = false;
  MapLibreMapController? _mapController;
  LatLng? _currentUserLocation;
  Circle? _userLocationCircle;
  Line? _routeLine;
  Fill? _territoryFill;
  StreamSubscription<Position>? _positionSubscription;
  Timer? _elapsedTimer;
  DateTime? _runStartedAt;
  Duration _elapsed = Duration.zero;
  double _distanceMeters = 0;
  final List<LatLng> _runRoutePoints = <LatLng>[];
  List<LatLng> _territoryBoundary = <LatLng>[];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ensureLocationPermission();
    });
  }

  Future<void> _ensureLocationPermission() async {
    final status = await Permission.locationWhenInUse.request();
    if (!mounted) return;

    final granted = status.isGranted;
    setState(() {
      _hasLocationPermission = granted;
    });

    if (!granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Location permission is needed to show your live position.',
          ),
        ),
      );
      return;
    }

    await _loadCurrentLocation();
  }

  Future<bool> _loadCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!mounted) return false;

    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please turn on location services to use live tracking.',
          ),
        ),
      );
      return false;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
        ),
      );
      if (!mounted) return false;

      final userLocation = LatLng(position.latitude, position.longitude);
      setState(() {
        _currentUserLocation = userLocation;
      });
      await _syncUserLocationMarker();
      if (_isRunning && _selectedMode == MapRunMode.solo) {
        await _recordRunPoint(userLocation);
      }
      await _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(userLocation, 15.5),
      );
      return true;
    } catch (_) {
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to fetch your current location right now.'),
        ),
      );
      return false;
    }
  }

  Future<void> _startLocationTracking() async {
    await _positionSubscription?.cancel();

    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 5,
    );

    _positionSubscription =
        Geolocator.getPositionStream(locationSettings: locationSettings).listen(
          (position) async {
            final userLocation = LatLng(position.latitude, position.longitude);
            if (!mounted) return;

            setState(() {
              _currentUserLocation = userLocation;
            });
            await _syncUserLocationMarker();
            if (_isRunning && _selectedMode == MapRunMode.solo) {
              await _recordRunPoint(userLocation);
            }

            await _mapController?.animateCamera(
              CameraUpdate.newLatLngZoom(userLocation, 17),
            );
          },
          onError: (_) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Live location tracking stopped unexpectedly.'),
              ),
            );
          },
        );
  }

  Future<void> _stopLocationTracking() async {
    await _positionSubscription?.cancel();
    _positionSubscription = null;
  }

  Future<void> _syncUserLocationMarker() async {
    final controller = _mapController;
    final userLocation = _currentUserLocation;
    if (!_isMapStyleReady || controller == null || userLocation == null) return;

    if (_userLocationCircle == null) {
      _userLocationCircle = await controller.addCircle(
        CircleOptions(
          geometry: userLocation,
          circleRadius: 9,
          circleColor: '#22C55E',
          circleStrokeColor: '#FFFFFF',
          circleStrokeWidth: 3,
          circleOpacity: 0.95,
        ),
      );
      return;
    }

    await controller.updateCircle(
      _userLocationCircle!,
      CircleOptions(geometry: userLocation),
    );
  }

  Future<void> _recordRunPoint(LatLng point) async {
    if (_runRoutePoints.isNotEmpty) {
      final previous = _runRoutePoints.last;
      final segmentMeters = Geolocator.distanceBetween(
        previous.latitude,
        previous.longitude,
        point.latitude,
        point.longitude,
      );
      if (segmentMeters < 3) {
        return;
      }
      _distanceMeters += segmentMeters;
    }

    _runRoutePoints.add(point);
    _territoryBoundary = _buildTerritoryBoundary(_runRoutePoints);

    if (mounted) {
      setState(() {});
    }
    await _syncRouteLine();
    await _syncTerritoryFill();
  }

  Future<void> _syncRouteLine() async {
    final controller = _mapController;
    if (!_isMapStyleReady || controller == null || _runRoutePoints.length < 2) {
      return;
    }

    final options = LineOptions(
      geometry: List<LatLng>.from(_runRoutePoints),
      lineColor: '#72B63E',
      lineWidth: 5,
      lineOpacity: 0.92,
      lineJoin: 'round',
      lineBlur: 0.4,
    );

    if (_routeLine == null) {
      _routeLine = await controller.addLine(options);
      return;
    }

    await controller.updateLine(_routeLine!, options);
  }

  Future<void> _syncTerritoryFill() async {
    final controller = _mapController;
    if (!_isMapStyleReady || controller == null) return;

    if (_territoryBoundary.length < 3) {
      return;
    }

    final closedLoop = List<LatLng>.from(_territoryBoundary);
    if (closedLoop.first != closedLoop.last) {
      closedLoop.add(closedLoop.first);
    }

    final options = FillOptions(
      geometry: [closedLoop],
      fillColor: '#72B63E',
      fillOpacity: 0.18,
      fillOutlineColor: '#3B6D11',
    );

    if (_territoryFill == null) {
      _territoryFill = await controller.addFill(options);
      return;
    }

    await controller.updateFill(_territoryFill!, options);
  }

  List<LatLng> _buildTerritoryBoundary(List<LatLng> points) {
    if (points.length < 3) {
      return List<LatLng>.from(points);
    }

    final uniquePoints = <_PointKey, LatLng>{};
    for (final point in points) {
      uniquePoints[_PointKey(point.latitude, point.longitude)] = point;
    }

    final sorted = uniquePoints.values.toList()
      ..sort((a, b) {
        final longitudeCompare = a.longitude.compareTo(b.longitude);
        if (longitudeCompare != 0) return longitudeCompare;
        return a.latitude.compareTo(b.latitude);
      });

    if (sorted.length < 3) {
      return sorted;
    }

    List<LatLng> buildHalf(Iterable<LatLng> source) {
      final hull = <LatLng>[];
      for (final point in source) {
        while (hull.length >= 2 &&
            _cross(hull[hull.length - 2], hull[hull.length - 1], point) <= 0) {
          hull.removeLast();
        }
        hull.add(point);
      }
      return hull;
    }

    final lower = buildHalf(sorted);
    final upper = buildHalf(sorted.reversed);
    lower.removeLast();
    upper.removeLast();
    return [...lower, ...upper];
  }

  double _cross(LatLng o, LatLng a, LatLng b) {
    return (a.longitude - o.longitude) * (b.latitude - o.latitude) -
        (a.latitude - o.latitude) * (b.longitude - o.longitude);
  }

  void _resetRunState() {
    _runStartedAt = null;
    _elapsed = Duration.zero;
    _distanceMeters = 0;
    _runRoutePoints.clear();
    _territoryBoundary = <LatLng>[];
    _elapsedTimer?.cancel();
    _elapsedTimer = null;
  }

  void _startElapsedTimer() {
    _elapsedTimer?.cancel();
    _runStartedAt = DateTime.now();
    _elapsed = Duration.zero;
    _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final startedAt = _runStartedAt;
      if (!mounted || startedAt == null) return;
      setState(() {
        _elapsed = DateTime.now().difference(startedAt);
      });
    });
  }

  Future<void> _centerOnUser() async {
    if (!_hasLocationPermission) {
      await _ensureLocationPermission();
      if (!_hasLocationPermission) return;
    }

    final loaded = await _loadCurrentLocation();
    if (!loaded || _currentUserLocation == null) return;

    await _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(_currentUserLocation!, 16.2),
    );
  }

  void _startRun() async {
    if (!_hasLocationPermission) {
      await _ensureLocationPermission();
      if (!_hasLocationPermission) return;
    }

    if (_currentUserLocation == null) {
      final loaded = await _loadCurrentLocation();
      if (!loaded) return;
    }

    _resetRunState();
    if (!mounted) return;
    setState(() => _isRunning = true);
    if (_currentUserLocation != null && _selectedMode == MapRunMode.solo) {
      await _recordRunPoint(_currentUserLocation!);
    }
    _startElapsedTimer();
    await _startLocationTracking();
    await _centerOnUser();
  }

  Future<void> _stopRun() async {
    await _stopLocationTracking();
    _elapsedTimer?.cancel();
    if (!mounted) return;
    setState(() => _isRunning = false);
    if (_selectedMode == MapRunMode.solo && _territoryBoundary.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Run saved: ${(_distanceMeters / 1000).toStringAsFixed(2)} km and territory marked.',
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _elapsedTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Full-bleed map, fills the entire screen behind everything else.
          MapLibreMap(
            styleString: _mapStyle,
            initialCameraPosition: const CameraPosition(
              target: _mapCenter,
              zoom: 15,
            ),
            onMapCreated: (controller) => _mapController = controller,
            onStyleLoadedCallback: () async {
              _isMapStyleReady = true;
              await _syncUserLocationMarker();
            },
            compassEnabled: false,
            // We track location with geolocator and move the camera ourselves.
            // Keeping MapLibre's native location layer off avoids the native
            // crash path that can happen right when permission is granted.
            myLocationEnabled: false,
            scrollGesturesEnabled: !_isRunning,
            zoomGesturesEnabled: !_isRunning,
            dragEnabled: !_isRunning,
            rotateGesturesEnabled: false,
            tiltGesturesEnabled: false,
            attributionButtonMargins: const Point(-1000, -1000),
          ),

          // Floating header + run type toggle, fades into the map below it.
          // Fills all the way behind the status bar/notch instead of
          // stopping at the SafeArea, and disappears once a run starts so
          // the map takes over the full screen.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              ignoring: _isRunning,
              child: AnimatedSlide(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                offset: _isRunning ? const Offset(0, -1) : Offset.zero,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 250),
                  opacity: _isRunning ? 0 : 1,
                  child: Container(
                    padding: EdgeInsets.fromLTRB(
                      18,
                      MediaQuery.of(context).padding.top + 8,
                      18,
                      24,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: isDark
                            ? const [
                                Color(0xFF07111A),
                                Color(0xF207111A),
                                Color(0xB307111A),
                                Color(0x0007111A),
                              ]
                            : const [
                                Color(0xFFFFFFFF),
                                Color(0xF2FFFFFF),
                                Color(0xB3FFFFFF),
                                Color(0x00FFFFFF),
                              ],
                        stops: [0.0, 0.45, 0.75, 1.0],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Map',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF111111),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Choose your run type and start tracking',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark
                                ? const Color(0xFF9BA8B4)
                                : const Color(0xFF8B8B8B),
                          ),
                        ),
                        const SizedBox(height: 14),
                        _RunTypeToggle(
                          selectedMode: _selectedMode,
                          onModeChanged: (mode) {
                            setState(() {
                              _selectedMode = mode;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Recenter button, floats over the map on the right. Hidden
          // while a run is active so the run stats own that space.
          Positioned(
            top: MediaQuery.of(context).padding.top + 150,
            right: 16,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 250),
              opacity: _isRunning ? 0 : 1,
              child: IgnorePointer(
                ignoring: _isRunning,
                child: _RecenterButton(onPressed: _centerOnUser),
              ),
            ),
          ),

          // Bottom tracking card, floats over the map. Sits right above
          // the app's own bottom nav bar with minimal gap.
          Positioned(
            left: 14,
            right: 14,
            bottom: 8,
            child: _TrackingCard(
              selectedMode: _selectedMode,
              isRunning: _isRunning,
              distanceKm: _distanceMeters / 1000,
              elapsed: _elapsed,
              territoryCount: _territoryBoundary.length >= 3 ? 1 : 0,
              onStartPressed: _startRun,
              onStopPressed: _stopRun,
              onTerritoriesPressed: () {
                if (_selectedMode != MapRunMode.group) return;

                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const LeaderboardScreen()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _RunTypeToggle extends StatelessWidget {
  const _RunTypeToggle({
    required this.selectedMode,
    required this.onModeChanged,
  });

  final MapRunMode selectedMode;
  final ValueChanged<MapRunMode> onModeChanged;

  static const _activeColor = Color(0xFF3B6D11);
  static const _inactiveColor = Color(0xFFA7AEAA);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 44,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xD9111C26) : const Color(0xE6F1F1EF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF233241) : const Color(0xFFD8D8D5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _RunTypeOption(
              icon: Icons.person_outline_rounded,
              label: 'Solo',
              isActive: selectedMode == MapRunMode.solo,
              activeColor: _activeColor,
              inactiveColor: _inactiveColor,
              onTap: () => onModeChanged(MapRunMode.solo),
            ),
          ),
          Expanded(
            child: _RunTypeOption(
              icon: Icons.groups_2_outlined,
              label: 'Group',
              isActive: selectedMode == MapRunMode.group,
              activeColor: _activeColor,
              inactiveColor: _inactiveColor,
              onTap: () => onModeChanged(MapRunMode.group),
            ),
          ),
        ],
      ),
    );
  }
}

class _RunTypeOption extends StatelessWidget {
  const _RunTypeOption({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.activeColor,
    required this.inactiveColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final Color activeColor;
  final Color inactiveColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isActive ? activeColor : inactiveColor;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isActive
            ? (isDark ? const Color(0xFF16222E) : Colors.white)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(9),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.06),
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
          borderRadius: BorderRadius.circular(9),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
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

class _RecenterButton extends StatelessWidget {
  const _RecenterButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xE6111C26) : const Color(0xD9FFFFFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF233241) : const Color(0xFFE7E7E4),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: const Icon(
            Icons.my_location_rounded,
            size: 17,
            color: Color(0xFF3B6D11),
          ),
        ),
      ),
    );
  }
}

class _TrackingCard extends StatelessWidget {
  const _TrackingCard({
    required this.selectedMode,
    required this.isRunning,
    required this.distanceKm,
    required this.elapsed,
    required this.territoryCount,
    required this.onStartPressed,
    required this.onStopPressed,
    required this.onTerritoriesPressed,
  });

  final MapRunMode selectedMode;
  final bool isRunning;
  final double distanceKm;
  final Duration elapsed;
  final int territoryCount;
  final VoidCallback onStartPressed;
  final VoidCallback onStopPressed;
  final VoidCallback onTerritoriesPressed;

  static const _brandGreen = Color(0xFF72B63E);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: isRunning
          ? _buildRunningCard(key: const ValueKey('running'), isDark: isDark)
          : _buildIdleCard(key: const ValueKey('idle'), isDark: isDark),
    );
  }

  Widget _buildRunningCard({required Key key, required bool isDark}) {
    return Container(
      key: key,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111C26) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? const Color(0xFF233241) : const Color(0xFFE4E4E1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          RichText(
            text: TextSpan(
              style: TextStyle(
                color: isDark ? Colors.white : Color(0xFF111111),
                fontWeight: FontWeight.w700,
              ),
              children: [
                TextSpan(
                  text: distanceKm.toStringAsFixed(2),
                  style: TextStyle(fontSize: 30),
                ),
                TextSpan(
                  text: ' km',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _formatDuration(elapsed),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF111111),
                ),
              ),
              Text(
                'Time',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? const Color(0xFF9BA8B4)
                      : const Color(0xFF9A9A9A),
                ),
              ),
            ],
          ),
          const Spacer(),
          SizedBox(
            height: 46,
            child: ElevatedButton.icon(
              onPressed: onStopPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A1A1A),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(23),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              icon: const Icon(Icons.stop_rounded, size: 18),
              label: const Text('Stop'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIdleCard({required Key key, required bool isDark}) {
    return Container(
      key: key,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111C26) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? const Color(0xFF233241) : const Color(0xFFE4E4E1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(
                Icons.directions_run_rounded,
                color: Color(0xFF67B337),
                size: 24,
              ),
              const SizedBox(width: 10),
              Text(
                'Live tracking',
                style: TextStyle(
                  fontSize: 15,
                  color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                ),
              ),
              const Spacer(),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onTerritoriesPressed,
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF233241)
                            : const Color(0xFFD7D7D7),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          selectedMode == MapRunMode.group
                              ? Icons.emoji_events_outlined
                              : Icons.map_outlined,
                          size: 18,
                          color: isDark
                              ? const Color(0xFF9BA8B4)
                              : const Color(0xFF8F9694),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          selectedMode == MapRunMode.group
                              ? 'Leadership'
                              : 'Territories${territoryCount > 0 ? ' ($territoryCount)' : ''}',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF1A1A1A),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 18,
                          color: isDark
                              ? const Color(0xFF9BA8B4)
                              : const Color(0xFF6E6E6E),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          RichText(
            text: TextSpan(
              style: TextStyle(
                color: isDark ? Colors.white : Color(0xFF111111),
                fontWeight: FontWeight.w700,
              ),
              children: [
                TextSpan(text: '0.00', style: TextStyle(fontSize: 44)),
                TextSpan(
                  text: ' km',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Distance',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? const Color(0xFF9BA8B4) : const Color(0xFF9A9A9A),
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: onStartPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: _brandGreen,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26),
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              icon: const Icon(Icons.play_arrow_rounded, size: 20),
              label: const Text('Start run'),
            ),
          ),
        ],
      ),
    );
  }
}

String _formatDuration(Duration duration) {
  final hours = duration.inHours.toString().padLeft(2, '0');
  final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
  final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
  return '$hours:$minutes:$seconds';
}

class _PointKey {
  const _PointKey(this.latitude, this.longitude);

  final double latitude;
  final double longitude;

  @override
  bool operator ==(Object other) {
    return other is _PointKey &&
        other.latitude == latitude &&
        other.longitude == longitude;
  }

  @override
  int get hashCode => Object.hash(latitude, longitude);
}
