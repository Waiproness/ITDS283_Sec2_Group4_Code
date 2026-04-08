import 'dart:typed_data'; 
import 'package:supabase_flutter/supabase_flutter.dart';

class RouteService {
  // สร้างตัวแปร _supabase ไว้เรียกใช้เพื่อความสั้นและสะอาดตา
  final _supabase = Supabase.instance.client;

  // ==========================================
  // 🔐 1. ระบบ Authentication (เข้าสู่ระบบ / สมัครสมาชิก)
  // ==========================================
  
  // แก้ฟังก์ชัน signUp ให้รับค่า name เข้ามาด้วย
  Future<AuthResponse> signUp(String email, String password, String name) async {
    try {
      return await _supabase.auth.signUp(
        email: email, 
        password: password,
        data: {'username': name}, // นำชื่อไปเซฟใน Metadata ของ Supabase
      );
    } catch (e) {
      print('Error signing up: $e');
      rethrow;
    }
  }

  Future<AuthResponse> signIn(String email, String password) async {
    try {
      return await _supabase.auth.signInWithPassword(email: email, password: password);
    } catch (e) {
      print('Error signing in: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // ดึงข้อมูล User ปัจจุบันที่ล็อกอินอยู่
  User? get currentUser => _supabase.auth.currentUser;

  // ==========================================
  // 👤 2. ระบบ Profile (อัปเดตชื่อและรูปโปรไฟล์)
  // ==========================================

  Future<String> uploadAvatar(Uint8List fileBytes, String fileExtension) async {
    try {
      final user = currentUser;
      if (user == null) throw Exception('User not logged in');

      // ตั้งชื่อไฟล์ไม่ให้ซ้ำกัน
      final fileName = 'avatar_${user.id}.${DateTime.now().millisecondsSinceEpoch}.$fileExtension';
      
      // อัปโหลดรูปไปที่ Bucket ชื่อ 'avatars'
      await _supabase.storage.from('avatars').uploadBinary(fileName, fileBytes);
      
      // ดึง URL กลับมา
      return _supabase.storage.from('avatars').getPublicUrl(fileName);
    } catch (e) {
      print('Error uploading avatar: $e');
      rethrow;
    }
  }

  Future<void> updateUserProfile(String username, String? avatarUrl) async {
    try {
      // เซฟข้อมูลลงใน User Metadata ของ Supabase Auth
      await _supabase.auth.updateUser(
        UserAttributes(
          data: {
            'username': username,
            if (avatarUrl != null) 'avatar_url': avatarUrl,
          },
        ),
      );
    } catch (e) {
      print('Error updating profile: $e');
      rethrow;
    }
  }

  // ==========================================
  // 🛣️ 3. ระบบจัดการเส้นทาง (Routes Map)
  // ==========================================

  // ดึงเส้นทาง "เฉพาะของเรา"
  Future<List<dynamic>> getRoutes() async {
    try {
      final userId = currentUser?.id;
      if (userId == null) return []; 

      return await _supabase
          .from('routes')
          .select()
          .eq('user_id', userId) 
          .order('created_at', ascending: false);
    } catch (e) {
      print('Error fetching routes: $e');
      return []; 
    }
  }

  // ดึงเส้นทางของ "ทุกคนในแอป"
  Future<List<dynamic>> getAllRoutes() async {
    try {
      return await _supabase.from('routes').select('*'); 
    } catch (e) {
      print('Error fetching all routes: $e');
      return [];
    }
  }

  Future<void> addRoute(Map<String, dynamic> routeData) async {
    try {
      await _supabase.from('routes').insert(routeData);
    } catch (e) {
      print('Error adding route: $e');
      rethrow; 
    }
  }

  Future<void> updateRoute(String id, Map<String, dynamic> routeData) async {
    try {
      await _supabase.from('routes').update(routeData).eq('id', id);
    } catch (e) {
      print('Error updating route: $e');
      rethrow;
    }
  }

  Future<void> deleteRoute(String id) async {
    try {
      await _supabase.from('routes').delete().eq('id', id);
    } catch (e) {
      print('Error deleting route: $e');
      rethrow;
    }
  }

  // อัปโหลดรูปภาพที่แนบไปกับเส้นทาง
  Future<String?> uploadImage(Uint8List imageBytes, String extension) async {
    try {
      final fileName = 'route_${DateTime.now().millisecondsSinceEpoch}.$extension';
      await _supabase.storage.from('route_images').uploadBinary(fileName, imageBytes);
      return _supabase.storage.from('route_images').getPublicUrl(fileName);
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }
  
  // ==========================================
  // 🚨 4. ระบบแจ้งปัญหา (Issues - ฟ้องด้วยภาพ)
  // ==========================================

  // อัปโหลดรูปลงกล่อง 'issues'
  Future<String> uploadIssueImage(Uint8List fileBytes, String fileExtension) async {
    try {
      final user = currentUser;
      if (user == null) throw Exception('User not logged in');

      final fileName = 'issue_${user.id}.${DateTime.now().millisecondsSinceEpoch}.$fileExtension';
      
      await _supabase.storage.from('issues').uploadBinary(fileName, fileBytes);
      return _supabase.storage.from('issues').getPublicUrl(fileName);
    } catch (e) {
      print('Error uploading issue image: $e');
      rethrow;
    }
  }

  // ส่งข้อมูลพิกัด/ข้อความเข้าตาราง 'issues'
  Future<void> submitIssue(Map<String, dynamic> issueData) async {
    try {
      await _supabase.from('issues').insert(issueData);
    } catch (e) {
      print('Error submitting issue: $e');
      rethrow;
    }
  }
}