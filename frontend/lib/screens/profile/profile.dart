import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';
import '../../services/route_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final Color primaryDarkTeal = const Color(0xFF0C8A8A);
  final Color primaryLightTeal = const Color(0xFF00CACA);

  String currentUsername = 'Theerawat Puvekit';
  String currentEmail = 'Loading...';
  String joinDate = 'Joined...'; 
  String? avatarUrl; 

  List<Map<String, dynamic>> myRoutes = [];
  final RouteService _routeService = RouteService(); 

  @override
  void initState() {
    super.initState();
    _loadProfileData();
    _loadUserInfo(); 
  }

  void _loadUserInfo() {
    final user = _routeService.currentUser;
    if (user != null) {
      setState(() {
        currentEmail = user.email ?? 'No Email';
        
        // ดึงชื่อและรูปภาพ
        final metaData = user.userMetadata;
        if (metaData != null) {
          if (metaData.containsKey('username')) currentUsername = metaData['username'];
          if (metaData.containsKey('avatar_url')) avatarUrl = metaData['avatar_url'];
        }

        // แปลงวันที่จากฐานข้อมูลมาแสดงผล
        if (user.createdAt.isNotEmpty) {
          DateTime date = DateTime.parse(user.createdAt);
          List<String> months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
          
          joinDate = 'Joined ${months[date.month - 1]} ${date.day}, ${date.year}';
        }
      });
    }
  }

  Future<void> _loadProfileData() async {
    try {
      final data = await _routeService.getRoutes();
      if (mounted) setState(() => myRoutes = data.map((e) => e as Map<String, dynamic>).toList());
    } catch (e) {
      if (mounted) setState(() => myRoutes = []);
    }
  }

  // ดึงเฉพาะตัวเลขออกมาจากข้อความ
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
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, bottom: 30, left: 20, right: 20),
      decoration: BoxDecoration(color: primaryDarkTeal, borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30))),
      child: Column(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: GestureDetector(
              onTap: () async {
                final result = await Navigator.pushNamed(
                  context, AppRoutes.profileEdit,
                  arguments: {
                    'initialUsername': currentUsername,
                    'initialEmail': currentEmail,
                    'initialAvatarUrl': avatarUrl, 
                    'joinDate': joinDate, 
                  },
                );
                if (result != null) _loadUserInfo(); 
              },
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                child: const Icon(Icons.settings, color: Colors.white, size: 20), // 👉 ไอคอนฟันเฟือง
              ),
            ),
          ),
          const SizedBox(height: 10),

          // โชว์รูปโปรไฟล์
          Container(
            width: 120, height: 120,
            decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFD9D9D9)),
            clipBehavior: Clip.hardEdge,
            child: avatarUrl != null 
                ? Image.network(avatarUrl!, fit: BoxFit.cover)
                : const Icon(Icons.person, size: 60, color: Colors.grey),
          ),
          const SizedBox(height: 20),

          Text(currentUsername, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text(currentEmail, style: const TextStyle(color: Colors.white70, fontSize: 16)),
          const SizedBox(height: 8),
          Text(joinDate, style: const TextStyle(color: Colors.white, fontSize: 14)), 
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    double overallDist = 0;
    double longestDist = 0;
    int createRouteCount = myRoutes.length;
    
    String latestActivity = myRoutes.isNotEmpty 
        ? (myRoutes.last['title']?.toString() ?? 'N/A') 
        : 'N/A';

    for (var route in myRoutes) {
      double dist = _parseDistance(route['distance']?.toString() ?? '0');
      overallDist += dist;
      if (dist > longestDist) {
        longestDist = dist;
      }
    }

    // 🔥 ฟังก์ชันจัดการระยะทาง (ถ้าไม่ถึง 1000 เมตร ให้โชว์เป็นตัวเลขเต็มๆ)
    String getDistValue(double m) {
      if (m < 1000) {
        return m.toStringAsFixed(0); 
      } else {
        double km = m / 1000;
        return km.truncateToDouble() == km 
            ? km.toStringAsFixed(0) 
            : km.toStringAsFixed(2); // ถ้าเกิน 1000 ค่อยใส่ทศนิยม 2 ตำแหน่ง
      }
    }

    // 🔥 ฟังก์ชันจัดการหน่วย (สลับ M กับ KM อัตโนมัติ)
    String getDistUnit(double m) {
      return m < 1000 ? 'M' : 'KM';
    }

    // 👉 นำฟังก์ชันมาใช้แทนของเดิมที่ล็อคตายตัว
    String overallStr = getDistValue(overallDist);
    String overallUnit = getDistUnit(overallDist);

    String longestStr = getDistValue(longestDist);
    String longestUnit = getDistUnit(longestDist);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildStatCard('Overall Route', overallStr, overallUnit)), // ส่งหน่วยที่คำนวณได้เข้าไป
              const SizedBox(width: 15),
              Expanded(child: _buildStatCard('Create Route', createRouteCount.toString(), 'Routes')),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(child: _buildStatCard('Longest Route', longestStr, longestUnit)), // ส่งหน่วยที่คำนวณได้เข้าไป
              const SizedBox(width: 15),
              Expanded(child: _buildStatCard('Latest Activity', latestActivity, '')),
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
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: Text(
                  value1,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (value2.isNotEmpty) const SizedBox(width: 5),
              if (value2.isNotEmpty)
                Text(
                  value2,
                  style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w600, fontSize: 16),
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
          _buildMenuItem(
            context,
            'Your Save Route',
           onTap: () async {
             await Navigator.pushNamed(context, AppRoutes.savedRoute);
             if (mounted) _loadProfileData(); 
           },
          ),
          const Divider(color: Colors.transparent, height: 10),
          _buildMenuItem(
            context,
            'Report Issues',
            onTap: () => Navigator.pushNamed(context, AppRoutes.reportIssues), 
          ),
          const Divider(color: Colors.transparent, height: 10),
          _buildMenuItem(
            context,
            'Team Credit',
            onTap: () => Navigator.pushNamed(context, AppRoutes.teamCredit), 
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, String title, {VoidCallback? onTap}) {
    return ListTile(
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18),
      onTap: onTap,
    );
  }
}