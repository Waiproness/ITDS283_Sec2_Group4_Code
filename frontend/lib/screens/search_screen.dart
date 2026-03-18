import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final Color _primaryTeal = const Color(0xFF008282);
  bool _isLoading = false;

  // ฟังก์ชันยิง API ไปถามหาพิกัดจากชื่อสถานที่
  Future<void> _searchPlace(String query) async {
    if (query.trim().isEmpty) return;
    
    setState(() => _isLoading = true);

    try {
      // ใช้ Nominatim API ของ OpenStreetMap (ฟรี)
      final url = 'https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=1';
      final response = await http.get(Uri.parse(url), headers: {
        'User-Agent': 'com.yourcompany.moremap' // ใส่ชื่อแพ็กเกจแอปเรา
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.isNotEmpty) {
          // ดึงค่าละติจูดและลองจิจูดจากผลลัพธ์แรก
          final lat = double.parse(data[0]['lat']);
          final lon = double.parse(data[0]['lon']);
          
          // ปิดหน้าจอนี้ แล้วส่งพิกัดกลับไปให้หน้าแผนที่หลัก
          Navigator.pop(context, LatLng(lat, lon));
        } else {
          // ถ้าหาสถานที่ไม่เจอ
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('ไม่พบสถานที่นี้ ลองพิมพ์ชื่อให้ชัดเจนขึ้นครับ')),
          );
        }
      }
    } catch (e) {
      print('Error searching place: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. แถบสีเขียวด้านบนพร้อมช่องค้นหา
          Container(
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
            child: Row(
              children: [
                // ปุ่มกดถอยหลัง (กันเหนียวให้ผู้ใช้กดกลับได้ง่ายๆ)
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      autofocus: true, // เปิดหน้ามาให้แป้นพิมพ์เด้งขึ้นมาเลย
                      textInputAction: TextInputAction.search, // เปลี่ยนปุ่มบนแป้นพิมพ์เป็นปุ่มค้นหา
                      onSubmitted: _searchPlace, // สั่งค้นหาเมื่อกดปุ่ม Enter
                      decoration: InputDecoration(
                        hintText: "Search",
                        hintStyle: TextStyle(color: Colors.grey[600], fontSize: 18),
                        prefixIcon: const Icon(Icons.search, color: Colors.black87, size: 28),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // แถบโหลดข้อมูล
          if (_isLoading) 
            LinearProgressIndicator(color: _primaryTeal, backgroundColor: Colors.transparent),

          // 2. ส่วนของประวัติการค้นหาล่าสุด (UI Mockup ตามรูปภาพ)
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Latest Search",
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
                const SizedBox(height: 15),
                _buildHistoryCard("สายใต้ใหม่"),
                const SizedBox(height: 10),
                _buildHistoryCard("มหาวิทยาลัยมหิดล"),
              ],
            ),
          ),
        ],
      ),
      
      // 3. แถบเมนูด้านล่างให้หน้าตาเหมือนหน้าหลัก
      bottomNavigationBar: _buildFakeBottomNav(),
    );
  }

  // วิดเจ็ตกล่องข้อความประวัติการค้นหา
  Widget _buildHistoryCard(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, color: Colors.black87),
      ),
    );
  }

  // วิดเจ็ตเมนูด้านล่าง (สร้างไว้แค่ให้ UI เหมือนหน้าหลัก)
  // วิดเจ็ตเมนูด้านล่าง
  Widget _buildFakeBottomNav() {
    return Container(
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
            // เพิ่ม onTap เพื่อสั่งให้ปิดหน้าค้นหาและกลับไปหน้าหลัก
            _buildNavItem(
              icon: Icons.location_on, 
              label: "Explore", 
              isActive: true,
              onTap: () {
                Navigator.pop(context); // คำสั่งกลับไปหน้า MainMaps
              }
            ),
            _buildNavItem(
              icon: Icons.add, 
              label: "AddRoute", 
              isLarge: true,
              onTap: () {
                // TODO: ใส่คำสั่งไปหน้า AddRoute ในอนาคต
              }
            ),
            _buildNavItem(
              icon: Icons.person_outline, 
              label: "Profile",
              onTap: () {
                // TODO: ใส่คำสั่งไปหน้า Profile ในอนาคต
              }
            ),
          ],
        ),
      ),
    );
  }

  // ปรับ _buildNavItem ให้รับค่า onTap เข้ามาได้ และใช้ InkWell เพื่อให้มีเอฟเฟกต์ตอนกด
  Widget _buildNavItem({required IconData icon, required String label, bool isActive = false, bool isLarge = false, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap, // นำ onTap มาใช้งานตรงนี้
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: isLarge ? 40 : 30, color: _primaryTeal),
          const SizedBox(height: 4),
          Text(
            label, 
            style: TextStyle(
              color: _primaryTeal, 
              fontSize: 12, 
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal
            )
          ),
        ],
      ),
    );
  }
  
}