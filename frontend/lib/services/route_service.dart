import 'dart:typed_data'; 
import 'package:supabase_flutter/supabase_flutter.dart';

class RouteService {
  final _supabase = Supabase.instance.client;

  // --- 🔐 Authentication ---
  Future<AuthResponse> signUp(String email, String password) async {
    try {
      return await _supabase.auth.signUp(email: email, password: password);
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

  User? get currentUser => _supabase.auth.currentUser;

  // 👉 1. ฟังก์ชันอัปเดตทั้งชื่อและรูปโปรไฟล์
  Future<void> updateUserProfile(String username, String? avatarUrl) async {
    try {
      // 🔥 ระบุชนิดตัวแปรให้ชัดเจน (แก้ปัญหาขีดแดงในโค้ด)
      final Map<String, dynamic> data = {'username': username};
      if (avatarUrl != null) {
        data['avatar_url'] = avatarUrl;
      }
      
      await _supabase.auth.updateUser(
        UserAttributes(data: data),
      );
    } catch (e) {
      print('Error updating profile: $e');
      rethrow; // ใช้ rethrow แทนเพื่อเก็บประวัติ Error ได้ดีขึ้น
    }
  }

  // 👉 2. ฟังก์ชันอัปโหลดรูปโปรไฟล์
  Future<String?> uploadAvatar(Uint8List imageBytes, String extension) async {
    try {
      final userId = _supabase.auth.currentUser!.id;
      final fileName = 'avatar_$userId.${DateTime.now().millisecondsSinceEpoch}.$extension';
      
      await _supabase.storage.from('avatars').uploadBinary(fileName, imageBytes);
      return _supabase.storage.from('avatars').getPublicUrl(fileName);
    } catch (e) {
      print('Error uploading avatar: $e');
      return null;
    }
  }

  // --- 🛣️ Routes ---
  Future<List<dynamic>> getRoutes() async {
    try {
      return await _supabase.from('routes').select().order('created_at', ascending: false);
    } catch (e) {
      print('Error fetching routes: $e');
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

  // --- 🖼️ Image Upload (สำหรับตอนเซฟแผนที่) ---
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
}