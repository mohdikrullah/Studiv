import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _campusController;
  late TextEditingController _semesterController;
  XFile? _image;
  Uint8List? _webImageBytes; // untuk preview di web

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    _nameController = TextEditingController(text: user?.fullName);
    _campusController = TextEditingController(text: user?.campus);
    _semesterController = TextEditingController(text: user?.semester?.toString());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _campusController.dispose();
    _semesterController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    if (image != null) {
      if (kIsWeb) {
        final bytes = await image.readAsBytes();
        setState(() {
          _image = image;
          _webImageBytes = bytes;
        });
      } else {
        setState(() => _image = image);
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    try {
      await authProvider.updateProfile(
        fullName: _nameController.text,
        campus: _campusController.text,
        semester: int.tryParse(_semesterController.text) ?? 1,
        imagePath: _image?.path,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil berhasil diperbarui!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memperbarui profil: $e'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          'EDIT PROFIL',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.slateDark),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (authProvider.isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(right: 16.0),
                child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
              ),
            )
          else
            TextButton(
              onPressed: _saveProfile,
              child: Text(
                'Simpan',
                style: GoogleFonts.inter(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar Section
              Center(
                child: Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.2), width: 2),
                      ),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: AppTheme.slateLight,
                        backgroundImage: _buildAvatarImage(_image, _webImageBytes, user?.profilePicture),
                        child: (_image == null && user?.profilePicture == null)
                            ? const Icon(Icons.person_rounded, size: 50, color: AppTheme.slateGray)
                            : null,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: AppTheme.primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.edit_rounded, color: Colors.white, size: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Form Elements
              _buildTextField('Nama Lengkap', _nameController, hint: 'Masukkan nama lengkap kamu'),
              const SizedBox(height: 24),
              _buildTextField('Kampus', _campusController, hint: 'Contoh: Universitas Gadjah Mada'),
              const SizedBox(height: 24),
              _buildTextField('Semester', _semesterController, hint: 'Contoh: 5', isNumber: true),
              
              const SizedBox(height: 48),
              
              // Bottom Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: authProvider.isLoading ? null : _saveProfile,
                  child: authProvider.isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Simpan Perubahan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Membangun ImageProvider yang sesuai platform
  ImageProvider? _buildAvatarImage(XFile? picked, Uint8List? webBytes, String? savedPath) {
    if (picked != null) {
      if (kIsWeb && webBytes != null) {
        return MemoryImage(webBytes);
      } else if (!kIsWeb) {
        return FileImage(File(picked.path));
      }
    }
    // Foto yang sudah tersimpan sebelumnya (path lokal)
    if (savedPath != null && savedPath.isNotEmpty) {
      if (kIsWeb) {
        return NetworkImage(savedPath); // web simpan sebagai URL
      } else {
        final f = File(savedPath);
        if (f.existsSync()) return FileImage(f);
      }
    }
    return null;
  }

  Widget _buildTextField(String label, TextEditingController controller, {String? hint, bool isNumber = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.slateDark,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          style: GoogleFonts.inter(fontSize: 15, color: AppTheme.slateDark),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(color: AppTheme.slateGray.withValues(alpha: 0.5), fontSize: 14),
          ),
          validator: (value) => value!.isEmpty ? 'Bagian ini tidak boleh kosong' : null,
        ),
      ],
    );
  }
}
