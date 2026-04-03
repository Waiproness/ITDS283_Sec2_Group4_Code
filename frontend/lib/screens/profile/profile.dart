import 'package:flutter/material.dart';
import 'Profile_edit.dart'; // ตรวจสอบชื่อไฟล์ให้ตรงกับของคุณ
import 'team_credit.dart';
import 'report_issues.dart';
import 'saved_route.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final Color primaryDarkTeal = const Color(0xFF0C8A8A);
  final Color primaryLightTeal = const Color(0xFF00CACA);
  final Color backgroundColor = const Color(0xFFF4F6F6);

  // 1. ข้อมูลผู้ใช้ (State)
  String currentUsername = 'Theerawat Puvekit';
  String currentPassword = '**************';
  String currentEmail = 'Theerawat.p@gmail.com';

  // 2. ข้อมูลรายการเส้นทาง (ย้ายมาจาก saved_route.dart เพื่อให้ Profile คำนวณได้)
  List<Map<String, String>> myRoutes = [
    {
      'title': 'Khlong Saan Sap',
      'distance': '1 km',
      'date': 'Feb 7, 2026', // เพิ่มวันที่จำลองสำหรับ Latest Activity
      'description':
          'Explore this for one reason!\nto Find One Piece Because\nof that we have to survey',
    },
    {
      'title': 'Suan Luang Rama IX',
      'distance': '5.5 km',
      'date': 'Feb 9, 2026',
      'description': 'Evening run at the park.',
    },
  ];

  // ฟังก์ชันช่วยดึงตัวเลขจาก '1 km' หรือ '203.5 KM' ให้ออกมาเป็นตัวเลขเพื่อคำนวณ
  double _parseDistance(String distanceStr) {
    final numericString = distanceStr.replaceAll(RegExp(r'[^0-9\.]'), '');
    if (numericString.isEmpty) return 0.0;
    return double.tryParse(numericString) ?? 0.0;
  }

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
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

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
          // ปุ่มไปหน้า Edit Profile
          Align(
            alignment: Alignment.topRight,
            child: GestureDetector(
              onTap: () async {
                // ส่งข้อมูลปัจจุบันไปหน้า Edit และรอรับค่ากลับ
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileEditPage(
                      initialUsername: currentUsername,
                      initialPassword: currentPassword,
                      initialEmail: currentEmail,
                    ),
                  ),
                );

                // หากมีการส่งข้อมูลกลับมา (กด Apply) ให้อัปเดตข้อมูลหน้าจอ
                if (result != null && result is Map<String, String>) {
                  setState(() {
                    currentUsername = result['username'] ?? currentUsername;
                    currentPassword = result['password'] ?? currentPassword;
                    currentEmail = result['email'] ?? currentEmail;
                  });
                }
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
              color: Color(0xFFD9D9D9),
            ),
          ),
          const SizedBox(height: 20),

          // แสดงชื่อผู้ใช้ล่าสุด
          Text(
            currentUsername,
            style: const TextStyle(
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

  Widget _buildStatsSection() {
    // คำนวณสถิติแบบ Real-time จาก myRoutes
    double overallDist = 0;
    double longestDist = 0;
    String latestDate = myRoutes.isNotEmpty
        ? myRoutes.last['date'] ?? 'N/A'
        : 'N/A';
    int createRouteCount = myRoutes.length;

    for (var route in myRoutes) {
      double dist = _parseDistance(route['distance'] ?? '0');
      overallDist += dist;
      if (dist > longestDist) {
        longestDist = dist;
      }
    }

    // จัด Format ตัวเลข (ถ้าลงตัวให้ตัดทศนิยมทิ้ง)
    String overallStr = overallDist.truncateToDouble() == overallDist
        ? overallDist.toStringAsFixed(0)
        : overallDist.toStringAsFixed(1);
    String longestStr = longestDist.truncateToDouble() == longestDist
        ? longestDist.toStringAsFixed(0)
        : longestDist.toStringAsFixed(1);

    // จัด Format วันที่ (แยก "Feb 9," และ "2026")
    List<String> dateParts = latestDate.split(' ');
    String val1 = dateParts.length >= 2
        ? '${dateParts[0]} ${dateParts[1]}'
        : latestDate;
    String val2 = dateParts.length >= 3 ? dateParts[2] : '';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard('Overall Route', overallStr, 'KM'),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildStatCard(
                  'Create Route',
                  createRouteCount.toString(),
                  'Route',
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: _buildStatCard('Longest Route', longestStr, 'KM'),
              ),
              const SizedBox(width: 15),
              Expanded(child: _buildStatCard('Lastest Activity', val1, val2)),
            ],
          ),
        ],
      ),
    );
  }

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
          // ไปหน้า Saved Route
          _buildMenuItem(
            context,
            'Your Save Route',
            onTap: () async {
              // ส่งรายการเส้นทางที่มีอยู่ไปให้หน้า Saved Route จัดการ
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SavedRoutePage(initialRoutes: myRoutes),
                ),
              );

              // ถ้ามีการแก้ไขเส้นทาง ให้เอาข้อมูลกลับมาทับของเดิม
              if (result != null && result is List<Map<String, String>>) {
                setState(() {
                  myRoutes = result;
                });
              }
            },
          ),
          const Divider(color: Colors.transparent, height: 10),

          // Report Issues
          _buildMenuItem(
            context,
            'Report Issues',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ReportIssuesPage(),
                ),
              );
            },
          ),
          const Divider(color: Colors.transparent, height: 10),

          // Team Credit
          _buildMenuItem(
            context,
            'Team Credit',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TeamCreditPage()),
              );
            },
          ),
        ],
      ),
    );
  }

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

  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
      decoration: BoxDecoration(color: backgroundColor),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.location_on, color: primaryDarkTeal, size: 30),
                  Text(
                    'Explore',
                    style: TextStyle(color: primaryDarkTeal, fontSize: 12),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {},
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, color: primaryDarkTeal, size: 40),
                  Text(
                    'AddRoute',
                    style: TextStyle(color: primaryDarkTeal, fontSize: 12),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {},
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.account_circle_outlined,
                    color: Colors.black,
                    size: 30,
                  ),
                  Text(
                    'Profile',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
