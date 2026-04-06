import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';
import '../../services/route_service.dart'; 

class SavedRoutePage extends StatefulWidget {
  const SavedRoutePage({super.key});

  @override
  State<SavedRoutePage> createState() => _SavedRoutePageState();
}

class _SavedRoutePageState extends State<SavedRoutePage> {
  final Color primaryDarkTeal = const Color(0xFF0C8A8A);
  
  List<Map<String, dynamic>> routes = []; 
  bool isLoading = true;

  final RouteService _routeService = RouteService();

  @override
  void initState() {
    super.initState();
    _fetchRoutesFromCloud(); 
  }

  Future<void> _fetchRoutesFromCloud() async {
    setState(() => isLoading = true);
    
    try {
      final List<dynamic> data = await _routeService.getRoutes();
      
      if (mounted) {
        setState(() {
          routes = data.map((e) => e as Map<String, dynamic>).toList();
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading routes: $e');
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('⚠️ ไม่สามารถเชื่อมต่อฐานข้อมูลได้'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF0C8A8A))) 
                : routes.isEmpty
                    ? const Center(child: Text('No saved routes found. ☁️', style: TextStyle(fontSize: 18, color: Colors.grey)))
                    : ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: routes.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 15),
                            child: _buildRouteCard(
                              context,
                              id: routes[index]['id']?.toString() ?? '', // 👉 1. ดึง id ออกมาจาก Cloud
                              title: routes[index]['title']?.toString() ?? 'Untitled',
                              distance: routes[index]['distance']?.toString() ?? '0 km',
                              description: routes[index]['description']?.toString() ?? '',
                              imageUrl: routes[index]['image_url']?.toString(), 
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 15, bottom: 25, left: 20, right: 20),
      decoration: BoxDecoration(color: primaryDarkTeal, borderRadius: const BorderRadius.vertical(bottom: Radius.circular(25))),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context), 
            child: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 10),
          const Text('Saved Route', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // 👉 2. เพิ่ม required String id ในฟังก์ชัน
  Widget _buildRouteCard(BuildContext context, {required String id, required String title, required String distance, required String description, String? imageUrl}) {
    return GestureDetector(
      onTap: () async {
        await Navigator.pushNamed(
          context,
          AppRoutes.routeDetail, // หรือไปหน้า Edit 
          arguments: {
            'id': id, // 👉 3. ส่งกุญแจ id ไปให้หน้าต่อไปด้วย!
            'title': title,
            'distance': distance,
            'description': description,
            'image_url': imageUrl, 
          },
        );

        if (mounted) {
          _fetchRoutesFromCloud(); 
        }
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: const Color(0xFFEEEEEE), borderRadius: BorderRadius.circular(15)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 22, color: Color(0xFF4A4A4A), fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text('Distance: $distance', style: const TextStyle(fontSize: 16, color: Color(0xFF6B6B6B))),
            const SizedBox(height: 15),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    description, 
                    maxLines: 2, 
                    overflow: TextOverflow.ellipsis, 
                    style: const TextStyle(fontSize: 16, color: Color(0xFF6B6B6B), height: 1.3)
                  )
                ),
                const Icon(Icons.arrow_forward, color: Colors.black87, size: 28),
              ],
            ),
          ],
        ),
      ),
    );
  }
}