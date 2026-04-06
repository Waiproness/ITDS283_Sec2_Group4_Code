import 'package:flutter/material.dart';
import 'constants/app_colors.dart';
import 'routes/app_routes.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // 👉 1. เพิ่ม Import Supabase
// (import ไฟล์ route อื่นๆ ของคุณตามปกติ...)

void main() async {
  // 👉 2. บรรทัดนี้สำคัญมาก! ต้องมีเมื่อเราใช้คำสั่ง async/await ใน main()
  WidgetsFlutterBinding.ensureInitialized(); 

  // 👉 3. เอา "กุญแจ" มาเสียบเพื่อเชื่อมต่อฐานข้อมูล
  await Supabase.initialize(
    url: 'https://veexhgknzwqddaweguur.supabase.co', // เอา API URL มาใส่ตรงนี้
    anonKey: 'sb_publishable_uQihulJX77O4j6t3w7Wkig_3d1LPfK2', // เอา Publishable Key ยาวๆ มาใส่ตรงนี้
  );

  runApp(const MoreMapApp());
}

class MoreMapApp extends StatelessWidget {
  const MoreMapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MoreMap',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primaryTeal,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryTeal),
        useMaterial3: true,
      ),
      
      // ให้หน้าแรกสุดเป็นหน้า Loading (SplashScreen)
      initialRoute: AppRoutes.splash, // หน้าแรกที่จะเปิด
      routes: AppRoutes.getRoutes(),  // โยนแผนที่ Routes ทั้งหมดให้ระบบ
    );
  }
}
