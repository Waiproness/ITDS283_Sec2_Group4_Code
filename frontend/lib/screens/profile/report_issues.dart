import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart'; 
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/route_service.dart'; // เช็ค path ให้ตรงกับโปรเจกต์คุณด้วยนะครับ

class ReportIssuesPage extends StatefulWidget {
  const ReportIssuesPage({super.key});

  @override
  State<ReportIssuesPage> createState() => _ReportIssuesPageState();
}

class _ReportIssuesPageState extends State<ReportIssuesPage> {
  final TextEditingController _descriptionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final RouteService _routeService = RouteService();

  Uint8List? _imageBytes;
  String _fileExtension = 'jpg';
  bool _isLoading = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  // 📸 ฟังก์ชันเปิดกล้องถ่ายรูป
  Future<void> _takePhoto() async {
    try {
      // แก้คำว่า camera เป็น gallery
      final XFile? photo = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      if (photo != null) {
        final bytes = await photo.readAsBytes();
        setState(() {
          _imageBytes = bytes;
          _fileExtension = photo.name.split('.').last;
        });
      }
    } catch (e) {
      print('Error taking photo: $e');
    }
  }

  // 📍 ดึงตำแหน่งปัจจุบัน
  Future<Position?> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 1. เช็คว่าเปิด GPS ในเครื่องหรือยัง
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print("Debug: GPS Service is disabled");
      return null;
    }

    // 2. เช็คและขอ Permission (สำคัญมากสำหรับเครื่องจริง)
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print("Debug: Permission denied");
        return null;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      print("Debug: Permission denied forever");
      return null;
    }

    // 3. ดึงพิกัด (เพิ่ม timeout เพื่อไม่ให้แอปค้าง)
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10), // ถ้า 10 วิหาไม่เจอ ให้ throw error
      );
    } catch (e) {
      print("Debug: GPS Timeout หรือหาพิกัดไม่ได้ - พยายามใช้ LastKnownPosition");
      // ถ้าหาพิกัดใหม่ไม่ได้ ให้ลองดึงพิกัดล่าสุดที่เครื่องเคยจำได้มาใช้แทนครับ
      return await Geolocator.getLastKnownPosition();
    }
  }

  // 🚀 ฟังก์ชันส่งข้อมูลขึ้น Cloud
  Future<void> _submitReport() async {
    if (_imageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('⚠️ กรุณาถ่ายรูปปัญหาก่อนส่งรายงาน'), backgroundColor: Colors.redAccent));
      return;
    }
    if (_descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('⚠️ กรุณาใส่คำอธิบายปัญหา'), backgroundColor: Colors.redAccent));
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. ดึงพิกัด
      final position = await _getCurrentLocation();
      if (position == null) throw Exception('Location not found');

      // 2. อัปโหลดรูป
      final imageUrl = await _routeService.uploadIssueImage(_imageBytes!, _fileExtension);

      // 3. เตรียมข้อมูล
      final user = Supabase.instance.client.auth.currentUser;
      final issueData = {
        'user_id': user?.id,
        'description': _descriptionController.text,
        'image_url': imageUrl,
        'lat': position.latitude,
        'lng': position.longitude,
      };

      // 4. บันทึกลงฐานข้อมูล
      await _routeService.submitIssue(issueData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ ส่งรายงานปัญหาสำเร็จ! ขอบคุณที่ช่วยชุมชนครับ'), backgroundColor: Colors.green));
        Navigator.pop(context); // ส่งเสร็จแล้วเด้งกลับหน้าเดิม
      }
    } catch (e) {
      print('Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('❌ เกิดข้อผิดพลาดในการส่งรายงาน'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C8A8A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Report Issues 🚨', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        margin: const EdgeInsets.only(top: 20),
        padding: const EdgeInsets.all(25.0),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('1. Capture Image', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 15),
              
              // กล่องรูปภาพ
              GestureDetector(
                onTap: _takePhoto,
                child: Container(
                  height: 250,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey.shade400, style: BorderStyle.solid),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: _imageBytes != null
                      ? Image.memory(_imageBytes!, fit: BoxFit.cover)
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt, size: 60, color: Colors.grey.shade500),
                            const SizedBox(height: 10),
                            Text('Insert Image', style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 30),

              const Text('2. Problems Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 15),
              
              // กล่องข้อความ
              TextField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'เช่น ทางเท้าพัง, ไฟถนนดับ, มีสิ่งกีดขวาง...',
                  hintStyle: TextStyle(color: Colors.grey[500], fontStyle: FontStyle.italic),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.all(15),
                ),
              ),
              const SizedBox(height: 40),

              // ปุ่มส่งข้อมูล
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitReport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD64444), // สีแดงเด่นๆ
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Submit Report 🚀', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}