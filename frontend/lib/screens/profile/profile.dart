import 'package:flutter/material.dart';
// 👉 1. Import Widget และ Routes เข้ามา
import '../../routes/app_routes.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  // กำหนดสีหลักเพื่อให้ง่ายต่อการแก้ไข
  final Color primaryDarkTeal = const Color(0xFF0C8A8A);
  final Color primaryLightTeal = const Color(0xFF00CACA);
  final Color backgroundColor = const Color(0xFFF4F6F6);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context),
            const SizedBox(height: 20),
            _buildStatsSection(),
            const SizedBox(height: 20),
            _buildMenuSection(context),
            const SizedBox(height: 40),
          ],
        ),
      ),
      // 👉 2. เรียกใช้ CustomBottomNavBar ของเราแทนการวาดใหม่
    );
  }

  // ส่วนหัว: รูปโปรไฟล์และข้อมูล
  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, bottom: 30, left: 20, right: 20),
      decoration: BoxDecoration(
        color: primaryDarkTeal,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Column(
        children: [
          // Setting Icon (ขวาบน) สำหรับกดไปหน้า Profile Edit
          Align(
            alignment: Alignment.topRight,
            child: GestureDetector(
              onTap: () {
                // 👉 3. เปลี่ยนมาใช้ AppRoutes คลีนๆ
                Navigator.pushNamed(context, AppRoutes.profileEdit);
              },
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(Icons.build, color: Colors.white, size: 20),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // รูป Profile
          Container(
            width: 120,
            height: 120,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFD9D9D9), // สีเทา Placeholder
            ),
          ),
          const SizedBox(height: 20),

          // ชื่อและวันที่
          const Text(
            'Theerawat Puvekit',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'เข้าร่วมเมื่อ 7 ก.พ. 2026',
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }

  // ส่วนสถิติ: 4 กล่อง
  Widget _buildStatsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildStatCard('Overall Route', '40', 'KM')),
              const SizedBox(width: 15),
              Expanded(child: _buildStatCard('Create Route', '4', 'Route')),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(child: _buildStatCard('Longest Route', '203.5', 'KM')),
              const SizedBox(width: 15),
              Expanded(
                child: _buildStatCard('Lastest Activity', 'Feb 9,', '2026'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // วิดเจ็ตย่อยสำหรับสร้างกล่องสถิติ
  Widget _buildStatCard(String title, String value1, String value2) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      decoration: BoxDecoration(
        color: primaryLightTeal,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value1,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              const SizedBox(width: 5),
              Text(
                value2,
                style: const TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ส่วนเมนูด้านล่าง
  Widget _buildMenuSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: primaryDarkTeal,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          // Your Save Route
          _buildMenuItem(
            context,
            'Your Save Route',
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.savedRoute); // 👉 เปลี่ยนมาใช้ AppRoutes
            },
          ),
          const Divider(color: Colors.transparent, height: 10),

          // Report Issues
          _buildMenuItem(
            context,
            'Report Issues',
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.reportIssues); // 👉 เปลี่ยนมาใช้ AppRoutes
            },
          ),
          const Divider(color: Colors.transparent, height: 10),

          // Team Credit
          _buildMenuItem(
            context,
            'Team Credit',
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.teamCredit); // 👉 เปลี่ยนมาใช้ AppRoutes
            },
          ),
        ],
      ),
    );
  }

  // วิดเจ็ตย่อยสำหรับสร้างปุ่มเมนูแต่ละอัน
  Widget _buildMenuItem(
    BuildContext context,
    String title, {
    VoidCallback? onTap,
  }) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        color: Colors.white,
        size: 18,
      ),
      onTap: onTap,
    );
  }
}