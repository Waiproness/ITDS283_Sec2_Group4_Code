import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../services/route_service.dart'; 

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _obscurePassword = true;
  bool _agreeTerms = true; 
  bool _isLoading = false; 

  // สร้าง Controller เพื่อดูดข้อความจากช่องพิมพ์
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final RouteService _routeService = RouteService(); 

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Back", style: TextStyle(color: Colors.black, fontSize: 16)),
        titleSpacing: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Register",
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: AppColors.primaryTeal),
              ),
              const SizedBox(height: 10),
              const Text("Please create a new account", style: TextStyle(fontSize: 16, color: Colors.black87)),
              const SizedBox(height: 40),

              // --- ช่องกรอก Name ---
              const Text("Name", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController, 
                decoration: InputDecoration(
                  hintText: "Enter your name...",
                  hintStyle: TextStyle(color: Colors.grey[500], fontStyle: FontStyle.italic),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.lightBlueAccent, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // --- ช่องกรอก Email ---
              const Text("Email", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController, 
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: "myemail@gmail.com",
                  hintStyle: TextStyle(color: Colors.grey[500], fontStyle: FontStyle.italic),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.lightBlueAccent, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // --- ช่องกรอก Password ---
              const Text("Password", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController, 
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  hintText: "Enter your password",
                  hintStyle: TextStyle(color: Colors.grey[500], fontStyle: FontStyle.italic),
                  filled: true,
                  fillColor: Colors.grey[100],
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: AppColors.primaryTeal),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.lightBlueAccent, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // --- Checkbox ยอมรับเงื่อนไข ---
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: _agreeTerms,
                      activeColor: AppColors.primaryTeal,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      onChanged: (value) {
                        setState(() {
                          _agreeTerms = value ?? false;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      "Agree the terms of use and privacy policy",
                      style: TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // --- ปุ่ม Sign up ---
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: (_agreeTerms && !_isLoading) ? () async {
                    // เช็กว่าพิมพ์ครบไหม (เพิ่มการเช็คชื่อด้วย)
                    if (_nameController.text.isEmpty || _emailController.text.isEmpty || _passwordController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please fill in all fields (Name, Email, Password)')),
                      );
                      return;
                    }

                    setState(() => _isLoading = true);

                    try {
                      // 👉 ส่งข้อมูล 3 อย่างไปให้ Service: อีเมล, รหัสผ่าน, และ ชื่อ
                      await _routeService.signUp(
                        _emailController.text.trim(),
                        _passwordController.text.trim(),
                        _nameController.text.trim(),
                      );
                      
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Registration Successful! 🎉'), backgroundColor: Colors.green),
                        );
                        Navigator.pop(context); // สมัครเสร็จ เด้งกลับไปหน้า Login อัตโนมัติ
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
                        );
                      }
                    } finally {
                      if (mounted) setState(() => _isLoading = false);
                    }
                  } : null, 
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryTeal,
                    disabledBackgroundColor: Colors.grey[400], 
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading 
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text(
                          "Sign up",
                          style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}