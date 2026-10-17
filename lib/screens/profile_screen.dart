// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:final_project/screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Uint8List? _imageBytes;
  final ImagePicker _picker = ImagePicker();
  final User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _loadSavedImage(); // قراءة الصورة المحفوظة فور فتح الشاشة
  }

  // 1. قراءة الصورة المحفوظة عبر SharedPreferences
  // 1. قراءة صورة الحساب الحالي فقط
Future<void> _loadSavedImage() async {
  try {
    // جلب بيانات المستخدم الحالي المباشرة من Firebase
    final user = FirebaseAuth.instance.currentUser;
    
    if (user == null || user.uid.isEmpty) {
      setState(() {
        _imageBytes = null;
      });
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    // مفتاح فريد جداً يعتمد على UID الخاص بالإيميل الحالي
    final String key = 'profile_image_${user.uid}';
    final String? base64Image = prefs.getString(key);

    if (base64Image != null && base64Image.isNotEmpty) {
      setState(() {
        _imageBytes = base64Decode(base64Image);
      });
    } else {
      // لو الإيميل جديد وما لوش صورة، تفريغ الشاشة من أي صورة سابقة
      setState(() {
        _imageBytes = null;
      });
    }
  } catch (e) {
    debugPrint("Error loading image: $e");
  }
}

// 2. حفظ صورة الحساب الحالي فقط
Future<void> _pickImage(ImageSource source) async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.uid.isEmpty) return;

    final XFile? pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      final base64String = base64Encode(bytes);

      final prefs = await SharedPreferences.getInstance();
      final String key = 'profile_image_${user.uid}';
      await prefs.setString(key, base64String);

      setState(() {
        _imageBytes = bytes;
      });
    }
  } catch (e) {
    debugPrint("Error picking image: $e");
  }
}

  void _showImagePickerModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Wrap(
            children: [
              const Center(
                child: Text(
                  'اختيار صورة الملف الشخصي',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                  color: Color(0xFF233B6E),
                ),
                title: const Text('اختيار من المعرض (Gallery)'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Color(0xFF233B6E)),
                title: const Text('التقاط صورة بالكاميرا (Camera)'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF233B6E);
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;

    final String name = currentUser?.displayName ?? 'لم يتم تحديد اسم';
    final String email = currentUser?.email ?? 'لا يوجد بريد إلكتروني';
    final String phone = currentUser?.phoneNumber ?? 'غير محدد';

    final double avatarSize = screenWidth * 0.26 > 120
        ? 120
        : (screenWidth * 0.26 < 80 ? 80 : screenWidth * 0.26);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.shopping_bag_outlined, color: Colors.amber, size: 28),
            SizedBox(width: 6),
            Text(
              'E-SHOP',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                'Profile',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.05,
          vertical: 10,
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),

            Center(
              child: GestureDetector(
                onTap: _showImagePickerModal,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      width: avatarSize,
                      height: avatarSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey.shade200,
                        border: Border.all(color: primaryColor, width: 2),
                      ),
                      child: ClipOval(
                        child: _imageBytes != null
                            ? Image.memory(
                                _imageBytes!,
                                fit: BoxFit.cover,
                                width: avatarSize,
                                height: avatarSize,
                              )
                            : (currentUser?.photoURL != null
                                  ? Image.network(
                                      currentUser!.photoURL!,
                                      fit: BoxFit.cover,
                                      width: avatarSize,
                                      height: avatarSize,
                                    )
                                  : Icon(
                                      Icons.person_outline,
                                      size: avatarSize * 0.55,
                                      color: Colors.grey,
                                    )),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(avatarSize * 0.07),
                      decoration: const BoxDecoration(
                        color: primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: avatarSize * 0.16,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            _buildProfileDetail('اسم المستخدم', name, screenWidth),
            _buildProfileDetail('البريد الإلكتروني', email, screenWidth),
            _buildProfileDetail('رقم الهاتف', phone, screenWidth),

            const SizedBox(height: 16),
            const Divider(),

            _buildMenuItem(
              Icons.shopping_bag_outlined,
              'الطلبات (Orders)',
              () {},
            ),
            _buildMenuItem(
              Icons.payment_outlined,
              'طريقة الدفع (Payment)',
              () {},
            ),
            _buildMenuItem(
              Icons.settings_outlined,
              'الإعدادات (Settings)',
              () {},
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  if (!mounted) return;
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                    (route) => false,
                  );
                },
                child: const Text(
                  'تسجيل الخروج',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileDetail(String label, String value, double screenWidth) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.left,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: screenWidth * 0.038 > 16 ? 16 : 14,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey,
              fontSize: screenWidth * 0.035 > 15 ? 15 : 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: const Color(0xFF233B6E)),
      title: Text(
        title,
        textAlign: TextAlign.right,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      ),
      trailing: const Icon(
        Icons.arrow_back_ios_new,
        size: 14,
        color: Colors.grey,
      ),
    );
  }
}
