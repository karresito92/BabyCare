import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:intl/intl.dart';
import '../../models/baby.dart';
import '../../services/api_service.dart';
import '../../services/image_service.dart';

class EditBabyScreen extends StatefulWidget {
  final Baby baby;

  const EditBabyScreen({super.key, required this.baby});

  @override
  State<EditBabyScreen> createState() => _EditBabyScreenState();
}

class _EditBabyScreenState extends State<EditBabyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();
  final _imageService = ImageService();
  
  late TextEditingController _nameController;
  late DateTime _birthDate;
  String? _photoBase64;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.baby.name);
    _birthDate = widget.baby.birthDate;
    _photoBase64 = widget.baby.photo;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF6BA3E8),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _birthDate) {
      setState(() {
        _birthDate = picked;
      });
    }
  }

  Future<void> _pickImage() async {
    // En web, abrir selector directamente
    if (kIsWeb) {
      final image = await _imageService.pickImageAsBase64();
      if (image != null) {
        setState(() {
          _photoBase64 = image;
        });
      }
      return;
    }

    // En móvil, mostrar menú completo
    await showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galería'),
              onTap: () async {
                Navigator.pop(context);
                final image = await _imageService.pickImageAsBase64();
                if (image != null) {
                  setState(() {
                    _photoBase64 = image;
                  });
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Cámara'),
              onTap: () async {
                Navigator.pop(context);
                final image = await _imageService.takePhotoAsBase64();
                if (image != null) {
                  setState(() {
                    _photoBase64 = image;
                  });
                }
              },
            ),
            if (_photoBase64 != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Eliminar foto', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _photoBase64 = null;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveBaby() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _apiService.updateBaby(
        babyId: widget.baby.id,
        name: _nameController.text.trim(),
        birthDate: _birthDate,
        photo: _photoBase64,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bebé actualizado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildPhotoWidget() {
    if (_photoBase64 != null && _photoBase64!.isNotEmpty) {
      try {
        final imageData = _photoBase64!.split(',').last;
        return Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            image: DecorationImage(
              image: MemoryImage(base64Decode(imageData)),
              fit: BoxFit.cover,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
        );
      } catch (e) {
        print('Error loading image: $e');
      }
    }
    
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: const Icon(
        Icons.child_care,
        color: Color(0xFF6BA3E8),
        size: 60,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Editar Bebé'),
        backgroundColor: const Color(0xFF6BA3E8),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar del bebé con botón de editar
              Center(
                child: Stack(
                  children: [
                    _buildPhotoWidget(),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFF6BA3E8),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),

              // Nombre
              const Text(
                'Nombre',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Nombre del bebé',
                  prefixIcon: const Icon(Icons.child_care, color: Color(0xFF6BA3E8)),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF6BA3E8), width: 2),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor ingresa un nombre';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Fecha de nacimiento
              const Text(
                'Fecha de nacimiento',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _selectDate,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Color(0xFF6BA3E8)),
                      const SizedBox(width: 12),
                      Text(
                        DateFormat('dd/MM/yyyy').format(_birthDate),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const Spacer(),
                      Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade400),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Botón guardar
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveBaby,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6BA3E8),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Guardar cambios',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}