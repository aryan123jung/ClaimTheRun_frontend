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
import 'dart:convert';
import 'dart:math';

import 'package:clain_the_run/features/home/presentation/widgets/activitycard.dart';
import 'package:clain_the_run/features/home/presentation/widgets/run_route_map_preview.dart';
import 'package:clain_the_run/features/map/data/datasources/run_api_service.dart';
import 'package:clain_the_run/features/map/data/models/run_record.dart';
import 'package:clain_the_run/features/map/presentation/pages/group_run_dashboard_screen.dart';
import 'package:clain_the_run/features/map/presentation/pages/territories_overview_screen.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum MapRunMode { solo, group }

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const _savedTerritoryKey = 'saved_solo_territory_boundary';
  final RunApiService _runApiService = RunApiService();
  static const _mapCenter = LatLng(27.7172, 85.3240);
  static const _idleZoom = 15.2;
  static const _idleTilt = 28.0;
  static const _idleBearing = -18.0;
  static const _runningZoom = 17.2;
  static const _runningTilt = 52.0;
  static const _runningBearing = -32.0;

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
  Circle? _userLocationGlowCircle;
  Line? _routeLine;
  Fill? _territoryFill;
  StreamSubscription<Position>? _positionSubscription;
  Timer? _elapsedTimer;
  DateTime? _runStartedAt;
  Duration _elapsed = Duration.zero;
  double _distanceMeters = 0;
  String? _latestSavedRunId;
  final List<LatLng> _runRoutePoints = <LatLng>[];
  List<LatLng> _territoryBoundary = <LatLng>[];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _restoreSavedTerritoryFromApi();
      _ensureLocationPermission();
    });
  }

  Future<void> _restoreSavedTerritoryFromApi() async {
    try {
      final runs = await _runApiService.fetchMyRuns();
      if (!mounted) return;

      final latestTerritoryRun = runs.firstWhere(
        (run) => run.hasTerritory,
        orElse: () => const RunRecord(
          id: '',
          title: null,
          distanceMeters: 0,
          durationSeconds: 0,
          routePoints: <LatLng>[],
          territoryPoints: <LatLng>[],
          createdAt: null,
          user: RunUserSummary(
            id: '',
            fullname: '',
            username: '',
            profileUrl: null,
          ),
        ),
      );

      if (latestTerritoryRun.id.isNotEmpty &&
          latestTerritoryRun.territoryPoints.length >= 3) {
        setState(() {
          _territoryBoundary = List<LatLng>.from(
            latestTerritoryRun.territoryPoints,
          );
          _latestSavedRunId = latestTerritoryRun.id;
        });
        await _persistSavedTerritory();
        await _syncTerritoryFill();
        return;
      }
    } catch (_) {
      // Fall back to local cache when backend data is unavailable.
    }

    await _restoreSavedTerritory();
  }

  Future<void> _restoreSavedTerritory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_savedTerritoryKey);
    if (raw == null || raw.isEmpty) return;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return;

      final restored = decoded
          .whereType<Map>()
          .map(
            (point) => LatLng(
              (point['lat'] as num).toDouble(),
              (point['lng'] as num).toDouble(),
            ),
          )
          .toList();

      if (restored.length < 3 || !mounted) return;

      setState(() {
        _territoryBoundary = restored;
      });
      await _syncTerritoryFill();
    } catch (_) {
      await prefs.remove(_savedTerritoryKey);
    }
  }

  Future<void> _persistSavedTerritory() async {
    final prefs = await SharedPreferences.getInstance();
    if (_territoryBoundary.length < 3) {
      await prefs.remove(_savedTerritoryKey);
      return;
    }

    final payload = _territoryBoundary
        .map(
          (point) => <String, double>{
            'lat': point.latitude,
            'lng': point.longitude,
          },
        )
        .toList();
    await prefs.setString(_savedTerritoryKey, jsonEncode(payload));
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
      await _animateToUserLocation(userLocation, isRunning: _isRunning);
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

            await _animateToUserLocation(userLocation, isRunning: _isRunning);
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
      _userLocationGlowCircle = await controller.addCircle(
        CircleOptions(
          geometry: userLocation,
          circleRadius: 19,
          circleColor: '#72B63E',
          circleOpacity: 0.18,
          circleBlur: 0.6,
        ),
      );
      _userLocationCircle = await controller.addCircle(
        CircleOptions(
          geometry: userLocation,
          circleRadius: 11,
          circleColor: '#2FD16C',
          circleStrokeColor: '#FFFFFF',
          circleStrokeWidth: 4,
          circleOpacity: 0.98,
        ),
      );
      return;
    }

    if (_userLocationGlowCircle != null) {
      await controller.updateCircle(
        _userLocationGlowCircle!,
        CircleOptions(geometry: userLocation),
      );
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

  String _formatElapsed(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  String _formatPace(double distanceMeters, int durationSeconds) {
    if (distanceMeters <= 0 || durationSeconds <= 0) return "0'00\"";
    final secondsPerKm = durationSeconds / (distanceMeters / 1000);
    final minutes = secondsPerKm ~/ 60;
    final seconds = (secondsPerKm.round() % 60).toString().padLeft(2, '0');
    return "$minutes'$seconds\"";
  }

  int _estimateCalories(double distanceMeters) {
    return ((distanceMeters / 1000) * 68).round();
  }

  String _formatRunSubtitle(DateTime dateTime) {
    final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final suffix = dateTime.hour >= 12 ? 'PM' : 'AM';
    return 'Today, $hour:$minute $suffix';
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

  Future<void> _clearRunOverlays() async {
    final controller = _mapController;
    if (controller == null) return;

    if (_routeLine != null) {
      await controller.removeLine(_routeLine!);
      _routeLine = null;
    }

    if (_territoryFill != null) {
      await controller.removeFill(_territoryFill!);
      _territoryFill = null;
    }
  }

  Future<void> _clearSavedRouteLineOnly() async {
    final controller = _mapController;
    if (controller == null) return;

    if (_routeLine != null) {
      await controller.removeLine(_routeLine!);
      _routeLine = null;
    }
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

    await _animateToUserLocation(
      _currentUserLocation!,
      isRunning: _isRunning,
      forceDuration: const Duration(milliseconds: 650),
    );
  }

  Future<void> _animateToUserLocation(
    LatLng userLocation, {
    required bool isRunning,
    Duration? forceDuration,
  }) async {
    final controller = _mapController;
    if (controller == null) return;

    final camera = CameraPosition(
      target: userLocation,
      zoom: isRunning ? _runningZoom : _idleZoom,
      tilt: isRunning ? _runningTilt : _idleTilt,
      bearing: isRunning ? _runningBearing : _idleBearing,
    );

    await controller.animateCamera(
      CameraUpdate.newCameraPosition(camera),
      duration: forceDuration ?? const Duration(milliseconds: 900),
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
    await _presentRunSummary();
  }

  Future<void> _presentRunSummary() async {
    if (!mounted) return;

    if (_runRoutePoints.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Run stopped. Move a little more to save a run.'),
        ),
      );
      await _resetRunPreview();
      return;
    }

    final activity = ActivityModel(
      title: _selectedMode == MapRunMode.solo ? 'My Run' : 'Group Run',
      subtitle: _formatRunSubtitle(DateTime.now()),
      distanceKm: _distanceMeters / 1000,
      totalTime: _formatElapsed(_elapsed),
      avgPace: _formatPace(_distanceMeters, _elapsed.inSeconds),
      calories: _estimateCalories(_distanceMeters),
      routePoints: List<LatLng>.from(_runRoutePoints),
    );

    final decision = await _showRunSummaryDecisionSheet(
      context,
      activity: activity,
    );

    if (!mounted) return;

    if (decision?.shouldSave == true) {
      await _saveCompletedRun(decision!.title);
      return;
    }

    await _clearRunOverlays();
    _resetRunState();
    if (!mounted) return;
    setState(() {
      _latestSavedRunId = null;
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Run not saved.')));
  }

  Future<void> _saveCompletedRun(String? title) async {
    try {
      final savedRun = await _runApiService.createRun(
        title: title,
        routePoints: List<LatLng>.from(_runRoutePoints),
        territoryPoints: List<LatLng>.from(_territoryBoundary),
        distanceMeters: _distanceMeters,
        durationSeconds: _elapsed.inSeconds,
      );
      _latestSavedRunId = savedRun.id;
      await _persistSavedTerritory();
      await _clearSavedRouteLineOnly();
      _runRoutePoints.clear();
      if (!mounted) return;
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Run saved and added to recent activity.'),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_runApiService.extractErrorMessage(error))),
      );
    }
  }

  Future<void> _resetRunPreview() async {
    if (_isRunning) {
      await _stopLocationTracking();
    }

    await _clearRunOverlays();
    _resetRunState();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_savedTerritoryKey);
    if (!mounted) return;

    setState(() {
      _isRunning = false;
    });

    if (_currentUserLocation != null) {
      await _animateToUserLocation(
        _currentUserLocation!,
        isRunning: false,
        forceDuration: const Duration(milliseconds: 650),
      );
    }
  }

  Future<void> _clearSavedTerritoryOnly() async {
    await _clearRunOverlays();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_savedTerritoryKey);
    if (!mounted) return;
    setState(() {
      _territoryBoundary = <LatLng>[];
      _latestSavedRunId = null;
    });
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
              zoom: _idleZoom,
              tilt: _idleTilt,
              bearing: _idleBearing,
            ),
            onMapCreated: (controller) => _mapController = controller,
            onStyleLoadedCallback: () async {
              _isMapStyleReady = true;
              await _syncUserLocationMarker();
              await _syncTerritoryFill();
            },
            compassEnabled: false,
            // We track location with geolocator and move the camera ourselves.
            // Keeping MapLibre's native location layer off avoids the native
            // crash path that can happen right when permission is granted.
            myLocationEnabled: false,
            scrollGesturesEnabled: !_isRunning,
            zoomGesturesEnabled: !_isRunning,
            dragEnabled: !_isRunning,
            rotateGesturesEnabled: !_isRunning,
            tiltGesturesEnabled: !_isRunning,
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
              onStartPressed: () {
                if (_selectedMode == MapRunMode.group) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const GroupRunDashboardScreen(),
                    ),
                  );
                  return;
                }
                _startRun();
              },
              onStopPressed: _stopRun,
              onResetPressed: _resetRunPreview,
              onTerritoriesPressed: () async {
                if (_selectedMode == MapRunMode.group) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const GroupRunDashboardScreen(),
                    ),
                  );
                  return;
                }
                final deleted = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(
                    builder: (_) => TerritoriesOverviewScreen(
                      currentUserTerritory: List<LatLng>.from(
                        _territoryBoundary,
                      ),
                      currentUserRunId: _latestSavedRunId,
                      fallbackCenter: _currentUserLocation ?? _mapCenter,
                    ),
                  ),
                );

                if (deleted == true) {
                  await _clearSavedTerritoryOnly();
                }
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
    final accentColor = isDark
        ? const Color(0xFF8BCF5A)
        : const Color(0xFF3B6D11);

    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [Color(0xF0192633), Color(0xE10E1822)]
              : const [Color(0xF9FFFFFF), Color(0xE8F4F5F1)],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(0xFF294055) : const Color(0xFFE6ECE5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.24 : 0.09),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(18),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.explore_rounded, size: 22, color: accentColor),
              const SizedBox(height: 1),
              Text(
                'Center',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: accentColor,
                  letterSpacing: 0.2,
                ),
              ),
            ],
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
    required this.onResetPressed,
    required this.onTerritoriesPressed,
  });

  final MapRunMode selectedMode;
  final bool isRunning;
  final double distanceKm;
  final Duration elapsed;
  final int territoryCount;
  final VoidCallback onStartPressed;
  final VoidCallback onStopPressed;
  final VoidCallback onResetPressed;
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
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [Color(0xFF11202B), Color(0xFF0A141C)]
              : const [Color(0xFFFFFFFF), Color(0xFFF5F7F2)],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark ? const Color(0xFF223748) : const Color(0xFFE4ECE0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.10),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFF72B63E).withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.route_rounded,
                  color: Color(0xFF5FA92D),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Solo Run Active',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF101414),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Territory capture is running live',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? const Color(0xFF8FA4B3)
                            : const Color(0xFF7E8580),
                      ),
                    ),
                  ],
                ),
              ),
              _LiveBadge(isDark: isDark),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _RunMetricTile(
                  label: 'Distance',
                  value: distanceKm.toStringAsFixed(2),
                  suffix: 'km',
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _RunMetricTile(
                  label: 'Time',
                  value: _formatDuration(elapsed),
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: onStopPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF151C1B),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              icon: const Icon(Icons.stop_circle_outlined, size: 20),
              label: const Text('Finish run'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIdleCard({required Key key, required bool isDark}) {
    final distanceLabel = distanceKm.toStringAsFixed(2);

    return Container(
      key: key,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [Color(0xFF111C26), Color(0xFF0A1218)]
              : const [Color(0xFFFFFFFF), Color(0xFFF7F9F4)],
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: isDark ? const Color(0xFF243646) : const Color(0xFFE4ECE0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.10),
            blurRadius: 24,
            offset: const Offset(0, 12),
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
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF172532)
                          : const Color(0xFFF8FAF7),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF294055)
                            : const Color(0xFFE1E7DE),
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
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF13212D) : const Color(0xFFF3F7EE),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFF72B63E).withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.straighten_rounded,
                        color: Color(0xFF67B337),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Distance ready',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF111111),
                        ),
                      ),
                    ),
                    Text(
                      territoryCount > 0 ? '$territoryCount zones' : 'No zones',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? const Color(0xFF8FA4B3)
                            : const Color(0xFF6D776F),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF111111),
                      fontWeight: FontWeight.w800,
                    ),
                    children: [
                      TextSpan(
                        text: distanceLabel,
                        style: const TextStyle(fontSize: 46),
                      ),
                      TextSpan(
                        text: ' km',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? const Color(0xFF8FA4B3)
                              : const Color(0xFF69706C),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Distance',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? const Color(0xFF8FA4B3)
                        : const Color(0xFF8E948E),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: distanceKm > 0 || territoryCount > 0
                      ? onResetPressed
                      : null,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isDark
                        ? const Color(0xFFD7E6D0)
                        : const Color(0xFF355B18),
                    side: BorderSide(
                      color: isDark
                          ? const Color(0xFF304556)
                          : const Color(0xFFD5E2CD),
                    ),
                    backgroundColor: isDark
                        ? const Color(0xFF13212D)
                        : const Color(0xFFF9FCF6),
                    disabledForegroundColor: isDark
                        ? const Color(0xFF61717E)
                        : const Color(0xFFA7B3A0),
                    disabledBackgroundColor: isDark
                        ? const Color(0xFF101821)
                        : const Color(0xFFF1F4EE),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  icon: const Icon(Icons.restart_alt_rounded, size: 20),
                  label: const Text(
                    'Reset',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 58,
                  child: ElevatedButton.icon(
                    onPressed: onStartPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _brandGreen,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    icon: const Icon(Icons.navigation_rounded, size: 22),
                    label: const Text('Start run'),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LiveBadge extends StatelessWidget {
  const _LiveBadge({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF72B63E).withValues(alpha: isDark ? 0.16 : 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.fiber_manual_record_rounded,
            size: 10,
            color: Color(0xFF67B337),
          ),
          SizedBox(width: 4),
          Text(
            'LIVE',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Color(0xFF67B337),
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _RunMetricTile extends StatelessWidget {
  const _RunMetricTile({
    required this.label,
    required this.value,
    required this.isDark,
    this.suffix,
  });

  final String label;
  final String value;
  final bool isDark;
  final String? suffix;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF162531) : const Color(0xFFF3F7EE),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF111111),
                fontWeight: FontWeight.w800,
              ),
              children: [
                TextSpan(text: value, style: const TextStyle(fontSize: 22)),
                if (suffix != null)
                  TextSpan(
                    text: ' $suffix',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? const Color(0xFF8FA4B3)
                          : const Color(0xFF69706C),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? const Color(0xFF8FA4B3) : const Color(0xFF7D847E),
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

Future<_RunSavePayload?> _showRunSummaryDecisionSheet(
  BuildContext context, {
  required ActivityModel activity,
}) {
  return showDialog<_RunSavePayload>(
    context: context,
    barrierDismissible: false,
    builder: (context) => _RunSummaryNameDialog(activity: activity),
  );
}

class _RunSummaryNameDialog extends StatefulWidget {
  const _RunSummaryNameDialog({required this.activity});

  final ActivityModel activity;

  @override
  State<_RunSummaryNameDialog> createState() => _RunSummaryNameDialogState();
}

class _RunSummaryNameDialogState extends State<_RunSummaryNameDialog> {
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.activity.title);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                'Run Details',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF72B63E),
                ),
              ),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _nameController,
              onChanged: (_) => setState(() {}),
              textInputAction: TextInputAction.done,
              maxLength: 80,
              decoration: InputDecoration(
                labelText: 'Run name',
                hintText: 'Morning Run',
                counterText: '',
                filled: true,
                fillColor: const Color(0xFFF5F6F2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFFD8D8D5)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFFD8D8D5)),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    _nameController.text.trim().isEmpty
                        ? widget.activity.title
                        : _nameController.text.trim(),
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111111),
                    ),
                  ),
                ),
                Text(
                  widget.activity.subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9A9A9A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Container(
                height: 160,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFD8D8D5)),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: RunRouteMapPreview(
                  routePoints: widget.activity.routePoints,
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                _RunSummaryStat(
                  icon: Icons.show_chart_rounded,
                  iconColor: const Color(0xFF6AB339),
                  value: widget.activity.distanceKm.toStringAsFixed(2),
                  label: 'Total Km',
                ),
                Container(width: 1, height: 40, color: const Color(0xFFD8D8D5)),
                _RunSummaryStat(
                  icon: Icons.timer_outlined,
                  iconColor: const Color(0xFF3D6FE0),
                  value: widget.activity.totalTime,
                  label: 'Total Time',
                ),
                Container(width: 1, height: 40, color: const Color(0xFFD8D8D5)),
                _RunSummaryStat(
                  icon: Icons.speed_rounded,
                  iconColor: const Color(0xFFB6A72E),
                  value: widget.activity.avgPace,
                  label: 'Avg Pace',
                ),
                Container(width: 1, height: 40, color: const Color(0xFFD8D8D5)),
                _RunSummaryStat(
                  icon: Icons.local_fire_department_rounded,
                  iconColor: const Color(0xFFE08A2E),
                  value: '${widget.activity.calories}',
                  label: 'Calories',
                ),
              ],
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(
                      context,
                    ).pop(const _RunSavePayload.discard()),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF4A4A4A),
                      side: const BorderSide(color: Color(0xFFD5D5D2)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: const Text("Don't Save"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(
                        _RunSavePayload.save(
                          _nameController.text.trim().isEmpty
                              ? widget.activity.title
                              : _nameController.text.trim(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF72B63E),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: const Text('Save Run'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RunSavePayload {
  const _RunSavePayload({required this.shouldSave, this.title});

  const _RunSavePayload.save(String title)
    : this(shouldSave: true, title: title);

  const _RunSavePayload.discard() : this(shouldSave: false);

  final bool shouldSave;
  final String? title;
}

class _RunSummaryStat extends StatelessWidget {
  const _RunSummaryStat({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 22, color: iconColor),
          const SizedBox(height: 8),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111111),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10, color: Color(0xFF6E6E6E)),
          ),
        ],
      ),
    );
  }
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
