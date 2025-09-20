import 'dart:io';
import 'package:absensi_apps/api/profile.dart';
import 'package:absensi_apps/extension/navigation.dart';
import 'package:absensi_apps/models/get_profile_model.dart';
import 'package:absensi_apps/views/about_screen.dart';
import 'package:absensi_apps/views/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  static const id = "/profile_screen";

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  GetProfileModel? _profile;
  bool _loading = true;
  bool _updating = false;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    try {
      final data = await ProfileAPI.getProfile();
      setState(() {
        _profile = data;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal memuat profil: $e")),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 512,
      maxHeight: 512,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
      await _uploadImage();
    }
  }

  Future<void> _uploadImage() async {
    if (_selectedImage == null) return;
    
    setState(() => _updating = true);
    
    try {
      await ProfileAPI.updateProfilePhoto(image: _selectedImage);
      await _fetchProfile();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text("Foto profil berhasil diperbarui")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal mengupload foto: $e")),
        );
      }
    } finally {
      setState(() {
        _updating = false;
        _selectedImage = null;
      });
    }
  }

  void _editProfile() {
    final nameController = TextEditingController(text: _profile?.data?.name);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title:  Text("Edit Profile"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration:  InputDecoration(
                labelText: "Nama",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:  Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                   SnackBar(content: Text("Nama tidak boleh kosong")),
                );
                return;
              }

              Navigator.pop(context);
              await _updateName(name);
            },
            child:  Text("Simpan"),
          ),
        ],
      ),
    );
  }

  Future<void> _updateName(String name) async {
    setState(() => _updating = true);
    try {
      await ProfileAPI.updateProfile(name: name);
      setState(() {
        if (_profile != null && _profile!.data != null) {
          _profile = GetProfileModel(
            message: _profile!.message,
            data: _profile!.data!.copyWith(name: name),
          );
        }
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text("Profil berhasil diperbarui")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal update: $e")),
        );
      }
    } finally {
      setState(() => _updating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return  Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final user = _profile?.data;
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title:  Text(
          "Profile",
          style: TextStyle(
            fontFamily: "StageGrotesk_Bold",
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor:  Color(0xFF1E3A8A),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchProfile,
        child: SingleChildScrollView(
          physics:  AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding:  EdgeInsets.all(20),
                color: Colors.white,
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        CircleAvatar(
                          radius: 45,
                          backgroundColor: Colors.grey[300],
                          backgroundImage: _getProfileImage(user),
                          child: _getProfilePlaceholder(user),
                        ),
                        if (_updating)
                           CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        if (!_updating)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _pickImage,
                              child: Container(
                                padding:  EdgeInsets.all(4),
                                decoration:  BoxDecoration(
                                  color: Colors.blue,
                                  shape: BoxShape.circle,
                                ),
                                child:  Icon(
                                  Icons.edit,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                     SizedBox(height: 16),
                    Text(
                      user?.name ?? "-",
                      style:  TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                     SizedBox(height: 4),
                    Text(
                      user?.email ?? "-",
                      style:  TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                     SizedBox(height: 4),
                    Text(
                      user?.trainingTitle ?? "Training tidak tersedia",
                      style:  TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
               SizedBox(height: 16),
              Container(
                color: Colors.white,
                child: Column(
                  children: [
                    _buildMenuItem(
                      icon: Icons.edit,
                      title: "Edit Profile",
                      onTap: _updating ? null : _editProfile,
                      trailing: _updating
                          ?  SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : null,
                    ),
                    _buildMenuItem(
                      icon: Icons.info_outline,
                      title: "Tentang Aplikasi",
                      onTap: () {
                        context.push(AboutScreen());
                      },
                    ),
                  ],
                ),
              ),
               SizedBox(height: 16),
              Container(
                color: Colors.white,
                child: _buildMenuItem(
                  icon: Icons.logout,
                  title: "Logout",
                  color: Colors.red,
                  onTap: _updating
                      ? null
                      : () {
                          Navigator.pushReplacementNamed(context, LoginScreen.id);
                        },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ImageProvider? _getProfileImage(Data? user) {
    if (_selectedImage != null) {
      return FileImage(_selectedImage!);
    } else if (user?.profilePhotoUrl != null && user!.profilePhotoUrl!.isNotEmpty) {
      return NetworkImage(user.profilePhotoUrl!);
    }
    return null;
  }

  Widget? _getProfilePlaceholder(Data? user) {
    if (_selectedImage != null || 
        (user?.profilePhotoUrl != null && user!.profilePhotoUrl!.isNotEmpty)) {
      return null;
    }
    return  Icon(Icons.person, size: 50, color: Colors.grey);
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    Color color = Colors.black,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: TextStyle(
          color: onTap == null ? Colors.grey : color,
          fontFamily: "StageGrotesk_Medium",
          fontSize: 16,
        ),
      ),
      trailing: trailing ??  Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
      contentPadding:  EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    );
  }
}

extension DataCopyWith on Data {
  Data copyWith({
    String? name,
    String? email,
    String? profilePhoto,
    String? profilePhotoUrl,
  }) {
    return Data(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      batchKe: batchKe,
      trainingTitle: trainingTitle,
      batch: batch,
      training: training,
      jenisKelamin: jenisKelamin,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
    );
  }
}