import 'dart:async'; // เพิ่มสำหรับการจัดการ Stream
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'search_screen.dart'; 

class MainMaps extends StatefulWidget {
  const MainMaps({super.key});

  @override
  State<MainMaps> createState() => _MainMapsState();
}

class _MainMapsState extends State<MainMaps> {
  final MapController _mapController = MapController();
  
  // ตัวแปรสำหรับเก็บพิกัดปัจจุบัน
  LatLng? _currentPosition;
  
  // ตัวแปรสำหรับดักฟังการเคลื่อนที่ (Stream)
  StreamSubscription<Position>? _positionStreamSubscription;
  /// เพื่อเช็กว่ากล้องแผนที่ควรจะจับจ้องอยู่ที่ตัวเราตลอดเวลาไหม
  bool _isFollowingUser = true;

  final LatLng _initialCenter = const LatLng(13.7946, 100.3236); // พิกัดเริ่มต้น
  final Color _primaryTeal = const Color(0xFF008282);

  @override
  void initState() {
    super.initState();
    // เริ่มติดตามพิกัดทันทีที่เปิดหน้านี้
    _startLocationTracking();
  }

  @override
  void dispose() {
    // สำคัญมาก: ต้องยกเลิกการติดตามพิกัดเมื่อปิดหน้าจอเพื่อประหยัดแบตเตอรี่
    _positionStreamSubscription?.cancel();
    super.dispose();
  }

  // ฟังก์ชันติดตามพิกัดแบบ Real-time
  Future<void> _startLocationTracking() async {
    bool serviceEnabled;
    LocationPermission permission;

    // เช็กว่าเปิด GPS หรือยัง
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    // เช็ก Permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;

    // ตั้งค่าความแม่นยำ (ขยับทุกๆ 5 เมตรให้อัปเดต 1 ครั้ง)
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5, 
    );

    // เปิดสตรีมรับพิกัดต่อเนื่อง
      _positionStreamSubscription = Geolocator.getPositionStream(locationSettings: locationSettings).listen(
      (Position position) {
        setState(() {
          _currentPosition = LatLng(position.latitude, position.longitude);
        });
        
        // อัปเดตบรรทัดนี้: ให้กล้องเลื่อนตามตัวเราเฉพาะตอนที่โหมด Following เปิดอยู่
        if (_isFollowingUser) {
          _mapController.move(_currentPosition!, _mapController.camera.zoom);
        }
      }
    );
  }

  // ฟังก์ชันสำหรับปุ่มเป้าเล็ง (กดแล้วเด้งกลับมาที่ตัวเรา)
  void _moveToCurrentLocation() {
    setState(() => _isFollowingUser = true); // เปิดโหมดกล้องเกาะติด
    if (_currentPosition != null) {
      _mapController.move(_currentPosition!, 16.0);
    } else {
      _startLocationTracking();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. แผนที่
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _initialCenter,
              initialZoom: 15.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.yourcompany.moremap',
              ),
              MarkerLayer(
                markers: [
                  // หมุดตำแหน่งปัจจุบัน
                  if (_currentPosition != null)
                    Marker(
                      point: _currentPosition!,
                      width: 50,
                      height: 50,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2), // เพิ่มขอบขาวให้ดูมีมิติ
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),

          // 2. แถบค้นหา
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 10,
                bottom: 15,
                left: 20,
                right: 20,
              ),
              decoration: BoxDecoration(
                color: _primaryTeal,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: GestureDetector( // <--- เปลี่ยนตรงนี้
                onTap: () async {
                  // สั่งเปิดหน้า SearchScreen และรอรับค่าพิกัดที่จะ return กลับมา
                  final LatLng? result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SearchScreen()),
                  );

                  // ถ้าได้พิกัดกลับมาจากการค้นหา
                  if (result != null) {
                    setState(() {
                      _isFollowingUser = false; // ปิดโหมดกล้องเกาะติดตัวเราชั่วคราว
                    });
                    // สั่งเลื่อนกล้องไปที่สถานที่เป้าหมาย
                    _mapController.move(result, 15.0); 
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 15),
                      const Icon(Icons.search, color: Colors.black87, size: 28),
                      const SizedBox(width: 10),
                      Text("Search", style: TextStyle(color: Colors.grey[600], fontSize: 18)),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 3. ปุ่มด้านขวา
          Positioned(
            top: 130,
            right: 15,
            child: Column(
              children: [
                // สั่งให้ปุ่ม GPS ดึงกล้องกลับมาที่ตัวเรา
                _buildMapButton(Icons.my_location, onPressed: _moveToCurrentLocation),
                const SizedBox(height: 10),
                _buildMapButton(Icons.explore_outlined, onPressed: () {}),
              ],
            ),
          ),
        ],
      ),

      // 4. แถบเมนูด้านล่าง
      bottomNavigationBar: Container(
        height: 85,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -2)),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(icon: Icons.location_on, label: "Explore", isActive: true),
              _buildNavItem(icon: Icons.add, label: "AddRoute", isLarge: true),
              _buildNavItem(icon: Icons.person_outline, label: "Profile"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMapButton(IconData icon, {required VoidCallback onPressed}) {
    return Container(
      width: 45,
      height: 45,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5, offset: const Offset(0, 2)),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.black87),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildNavItem({required IconData icon, required String label, bool isActive = false, bool isLarge = false}) {
    return InkWell(
      onTap: () {},
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: isLarge ? 40 : 30, color: _primaryTeal),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(color: _primaryTeal, fontSize: 12, fontWeight: isActive ? FontWeight.bold : FontWeight.normal),
          ),
        ],
      ),
    );
  }
}