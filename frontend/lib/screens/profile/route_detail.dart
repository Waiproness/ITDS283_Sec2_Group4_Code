import 'package:flutter/material.dart';
import '../../routes/app_routes.dart'; 

class RouteDetailPage extends StatefulWidget {
  const RouteDetailPage({super.key});

  @override
  State<RouteDetailPage> createState() => _RouteDetailPageState();
}

class _RouteDetailPageState extends State<RouteDetailPage> {
  // 👉 1. เพิ่มตัวแปรสำหรับเก็บรหัส id
  late String routeId; 
  late String displayTitle;
  late String displayDescription;
  late String displayDistance;
  String? displayImageUrl; 
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    if (!_isInitialized) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      
      // 👉 2. รับ id ที่ส่งมาจากหน้า Saved Route เก็บไว้ในกระเป๋า
      routeId = args?['id']?.toString() ?? '';
      displayTitle = args?['title'] ?? 'Unknown Route';
      displayDescription = args?['description'] ?? 'No description provided.';
      displayDistance = args?['distance'] ?? '0 km';
      displayImageUrl = args?['image_url']; 
      
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
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
                          onPressed: () => Navigator.pop(context),
                        ),
                        // ✏️ 👉 3. ปุ่มแก้ไข (ส่ง id ต่อไปให้หน้า Edit)
                        ElevatedButton.icon(
                          onPressed: () async {
                            final result = await Navigator.pushNamed(
                              context,
                              AppRoutes.routeDetailEdit,
                              arguments: {
                                'id': routeId, // 🔥 ส่งกุญแจสำคัญไปให้หน้า Edit!
                                'title': displayTitle,
                                'distance': displayDistance,
                                'description': displayDescription,
                                'image_url': displayImageUrl,
                                'isNewRoute': false, // บอกหน้า Edit ว่านี่คือการแก้ไขของเก่า
                              },
                            );

                            // ถ้ามีการแก้ไข/ลบ และเด้งกลับมาหน้านี้ ให้อัปเดต UI หรือปิดหน้านี้ไปเลย
                            if (result != null && mounted) {
                              Navigator.pop(context); // ปิดหน้านี้เพื่อกลับไปรีเฟรชหน้าลิสต์
                            }
                          },
                          icon: const Icon(Icons.edit, size: 18, color: Colors.white),
                          label: const Text("Edit", style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00CACA),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // การแสดงผลข้อมูล (UI เดิมของคุณ)
                    Text(
                      'Route: $displayTitle',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Distance: $displayDistance',
                      style: const TextStyle(fontSize: 18, color: Colors.black54),
                    ),
                    const SizedBox(height: 25),

                    // กล่องแสดงรูปภาพ
                    Container(
                      height: 220,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      clipBehavior: Clip.hardEdge,
                      child: (displayImageUrl != null && displayImageUrl!.isNotEmpty)
                          ? Image.network(displayImageUrl!, fit: BoxFit.cover)
                          : const Center(child: Icon(Icons.image, size: 50, color: Colors.grey)),
                    ),
                    const SizedBox(height: 25),

                    // คำอธิบาย
                    const Text(
                      'Description:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      displayDescription,
                      style: const TextStyle(fontSize: 16, color: Colors.black87, height: 1.4),
                    ),
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