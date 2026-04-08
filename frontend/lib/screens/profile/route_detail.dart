import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart'; 
import 'package:latlong2/latlong.dart';      
import '../../routes/app_routes.dart'; 

class RouteDetailPage extends StatefulWidget {
  const RouteDetailPage({super.key});

  @override
  State<RouteDetailPage> createState() => _RouteDetailPageState();
}

class _RouteDetailPageState extends State<RouteDetailPage> {
  late String routeId; 
  late String displayTitle;
  late String displayDescription;
  late String displayDistance;
  String? displayImageUrl; 
  List<LatLng> _routePoints = []; 
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    if (!_isInitialized) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      
      routeId = args?['id']?.toString() ?? '';
      displayTitle = args?['title'] ?? 'Unknown Route';
      displayDescription = args?['description'] ?? 'No description provided.';
      displayDistance = args?['distance'] ?? '0 km';
      displayImageUrl = args?['image_url']; 
      
      if (args?['routePoints'] != null) {
        List<dynamic> pointsJson = args?['routePoints'];
        _routePoints = pointsJson.map((p) {
          return LatLng((p['lat'] as num).toDouble(), (p['lng'] as num).toDouble());
        }).toList();
      }

      _isInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C8A8A),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFEBEBEB),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ส่วนหัว: ปุ่ม Back และปุ่ม Edit
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF989898),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            elevation: 0,
                          ),
                          child: const Text('Back', style: TextStyle(color: Colors.white, fontSize: 18)),
                        ),
                        ElevatedButton.icon(
                          onPressed: () async {
                            final result = await Navigator.pushNamed(
                              context,
                              AppRoutes.routeDetailEdit,
                              arguments: {
                                'id': routeId, 
                                'title': displayTitle,
                                'distance': displayDistance,
                                'description': displayDescription,
                                'image_url': displayImageUrl,
                                'routePoints': _routePoints, 
                                'isNewRoute': false, 
                              },
                            );

                            if (result != null && mounted) {
                              Navigator.pop(context, true); 
                            }
                          },
                          icon: const Icon(Icons.edit, size: 18, color: Colors.black87),
                          label: const Text("Edit", style: TextStyle(color: Colors.black87)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00CACA),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            elevation: 0,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    Text('Route: $displayTitle', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
                    const SizedBox(height: 10),
                    Text('Distance: $displayDistance', style: const TextStyle(fontSize: 18, color: Colors.black54)),
                    const SizedBox(height: 25),

                    // 🔥 กล่องแผนที่พรีวิว (แก้บัคจอแดง NaN แล้ว) 🔥
                    if (_routePoints.isNotEmpty) ...[
                      Builder(
                        builder: (context) {
                          // เช็คการเคลื่อนที่เหมือนในหน้า Edit
                          bool hasRealMovement = _routePoints.length > 1 && 
                              _routePoints.any((p) => p.latitude != _routePoints.first.latitude || p.longitude != _routePoints.first.longitude);

                          return Container(
                            height: 200,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey.shade400, width: 2),
                            ),
                            clipBehavior: Clip.hardEdge,
                            child: FlutterMap(
                              options: MapOptions(
                                initialCenter: _routePoints.first,
                                initialZoom: 16.0,
                                initialCameraFit: hasRealMovement
                                    ? CameraFit.bounds(
                                        bounds: LatLngBounds.fromPoints(_routePoints),
                                        padding: const EdgeInsets.all(25.0),
                                      )
                                    : null,
                                interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
                              ),
                              children: [
                                TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'com.example.moremap'),
                                PolylineLayer(
                                  polylines: [Polyline(points: _routePoints, strokeWidth: 5.0, color: Colors.redAccent)],
                                ),
                                MarkerLayer(
                                  markers: [
                                    Marker(point: _routePoints.first, width: 14, height: 14, child: Container(decoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)))),
                                    Marker(point: _routePoints.last, width: 14, height: 14, child: Container(decoration: BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)))),
                                  ],
                                )
                              ],
                            ),
                          );
                        }
                      ),
                      const SizedBox(height: 20),
                    ],

                    // กล่องแสดงรูปภาพ
                    Container(
                      height: 220,
                      width: double.infinity,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                      clipBehavior: Clip.hardEdge,
                      child: (displayImageUrl != null && displayImageUrl!.isNotEmpty)
                          ? Image.network(displayImageUrl!, fit: BoxFit.cover)
                          : const Center(child: Icon(Icons.image, size: 50, color: Colors.grey)),
                    ),
                    const SizedBox(height: 25),

                    // คำอธิบาย
                    const Text('Description:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                    const SizedBox(height: 8),
                    Text(displayDescription, style: const TextStyle(fontSize: 16, color: Colors.black87, height: 1.4)),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}