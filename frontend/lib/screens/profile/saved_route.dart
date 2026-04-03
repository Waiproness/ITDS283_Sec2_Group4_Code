import 'package:flutter/material.dart';
import 'route_detail.dart';

class SavedRoutePage extends StatefulWidget {
  // รับข้อมูล List มาจากหน้า Profile
  final List<Map<String, String>> initialRoutes;

  const SavedRoutePage({super.key, required this.initialRoutes});

  @override
  State<SavedRoutePage> createState() => _SavedRoutePageState();
}

class _SavedRoutePageState extends State<SavedRoutePage> {
  final Color primaryDarkTeal = const Color(0xFF0C8A8A);

  late List<Map<String, String>> routes;

  @override
  void initState() {
    super.initState();
    // คัดลอกข้อมูลใส่ตัวแปรภายในหน้านี้
    routes = List<Map<String, String>>.from(widget.initialRoutes);
  }

  @override
  Widget build(BuildContext context) {
    // ใช้ WillPopScope เพื่อดักจับตอนกดปุ่มย้อนกลับของมือถือ (Android Back Button) เพื่อส่งข้อมูลกลับด้วย
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, routes);
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: routes.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: _buildRouteCard(
                      context,
                      index: index,
                      title: routes[index]['title']!,
                      distance: routes[index]['distance']!,
                      description: routes[index]['description']!,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 15,
        bottom: 25,
        left: 20,
        right: 20,
      ),
      decoration: BoxDecoration(
        color: primaryDarkTeal,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(25)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              // กดปุ่ม Back ซ้ายบน ให้ส่งข้อมูล routes ทั้งหมดกลับไปหน้า Profile
              Navigator.pop(context, routes);
            },
            child: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'Saved Route',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteCard(
    BuildContext context, {
    required int index,
    required String title,
    required String distance,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFEEEEEE),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 22, color: Color(0xFF4A4A4A)),
          ),
          const SizedBox(height: 10),
          Text(
            'Distances $distance',
            style: const TextStyle(fontSize: 16, color: Color(0xFF6B6B6B)),
          ),
          const SizedBox(height: 15),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  description,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF6B6B6B),
                    height: 1.3,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () async {
                  // รอรับข้อมูลจากหน้า Detail เผื่อว่ามีการแก้ไขเส้นทางนั้นๆ
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RouteDetailPage(
                        title: title,
                        distance: distance,
                        description: description,
                      ),
                    ),
                  );

                  if (result != null && result is Map<String, String>) {
                    setState(() {
                      routes[index]['title'] = result['title']!;
                      routes[index]['description'] = result['description']!;
                    });
                  }
                },
                child: const Icon(
                  Icons.arrow_forward,
                  color: Colors.black87,
                  size: 28,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
