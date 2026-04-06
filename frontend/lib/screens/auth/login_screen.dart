import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../routes/app_routes.dart';
import '../../services/route_service.dart'; // 👉 1. Import Service

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;
  bool _isLoading = false; // 👉 2. ตัวแปรคุมสถานะการโหลด

  // 👉 3. สร้าง Controller สำหรับดึงค่าจากช่องพิมพ์
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final RouteService _routeService = RouteService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              const Text(
                "Login",
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: AppColors.primaryTeal),
              ),
              const SizedBox(height: 10),
              const Text("Please sign in to continue", style: TextStyle(fontSize: 16, color: Colors.black87)),
              const SizedBox(height: 50),

              // --- ช่องกรอก Email ---
              const Text("Email", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController, // 👉 ผูก Controller
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: "myemail@gmail.com",
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.lightBlueAccent, width: 1.5)),
                ),
              ),
              const SizedBox(height: 20),

              // --- ช่องกรอก Password ---
              const Text("Password", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController, // 👉 ผูก Controller
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  hintText: "••••••••",
                  filled: true,
                  fillColor: Colors.grey[100],
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: AppColors.primaryTeal),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.lightBlueAccent, width: 1.5)),
                ),
              ),
              const SizedBox(height: 10),

              // Forgot Password (UI เฉยๆ)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: const Text("Forgot Password?", style: TextStyle(color: AppColors.primaryTeal, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 30),

              // --- 👉 4. ปุ่ม Login (เชื่อมต่อ Supabase) ---
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : () async {
                    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter email and password')));
                      return;
                    }

                    setState(() => _isLoading = true); // เริ่มหมุน

                    try {
                      // สั่งล็อกอินผ่าน Service
                      await _routeService.signIn(
                        _emailController.text.trim(),
                        _passwordController.text.trim(),
                      );
                      
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Login Successful! 🚀'), backgroundColor: Colors.green),
                        );
                        // ล็อกอินสำเร็จ ส่งไปหน้า Main (ที่มีแผนที่และ Profile)
                        Navigator.pushReplacementNamed(context, AppRoutes.mainMap);
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Login Failed: อีเมลหรือรหัสผ่านไม่ถูกต้อง'), backgroundColor: Colors.red),
                        );
                      }
                    } finally {
                      if (mounted) setState(() => _isLoading = false); // หยุดหมุน
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryTeal,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: _isLoading 
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text("LOGIN", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 40),

              // ไปหน้า Register
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account? "),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, AppRoutes.register),
                      child: const Text("Sign up", style: TextStyle(color: AppColors.primaryTeal, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}