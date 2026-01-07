import 'package:flutter/material.dart';
import 'dart:convert';
import '../../services/api_service.dart';
import '../../models/baby.dart';
import 'edit_baby_screen.dart';

class BabyProfileScreen extends StatefulWidget {
  final int babyId;

  const BabyProfileScreen({super.key, required this.babyId});

  @override
  State<BabyProfileScreen> createState() => _BabyProfileScreenState();
}

class _BabyProfileScreenState extends State<BabyProfileScreen> {
  final _apiService = ApiService();

  Baby? _baby;
  List<Map<String, dynamic>> _caregivers = [];
  bool _isLoading = true;
  bool _isOwner = false;

  @override
  void initState() {
    super.initState();
    _loadBabyData();
  }

  Future<void> _loadBabyData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load baby info
      final babyData = await _apiService.getBaby(widget.babyId);
      _baby = Baby.fromJson(babyData);

      // Load caregivers
      final caregiversData =
          await _apiService.getBabyCaregivers(babyId: widget.babyId);
      _caregivers = List<Map<String, dynamic>>.from(caregiversData);

      // Check if current user is owner
      _isOwner = _caregivers.any((c) => c['role'] == 'owner');
    } catch (e) {
      print('Error loading baby data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar datos: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addCaregiver() async {
    final emailController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Añadir cuidador'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Ingresa el email del cuidador que deseas añadir:'),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final email = emailController.text.trim();
              if (email.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Por favor ingresa un email'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }

              try {
                await _apiService.addCaregiver(
                  babyId: widget.babyId,
                  email: email,
                );
                if (context.mounted) {
                  Navigator.pop(context, true);
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6BA3E8),
            ),
            child: const Text('Añadir'),
          ),
        ],
      ),
    );

    if (result == true) {
      _loadBabyData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cuidador añadido exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _removeCaregiver(int caregiverId, String userName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar cuidador'),
        content: Text('¿Estás seguro de eliminar a $userName como cuidador?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _apiService.removeCaregiver(
          babyId: widget.babyId,
          caregiverId: caregiverId,
        );
        _loadBabyData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cuidador eliminado'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Widget _buildBabyAvatar() {
    if (_baby?.photo != null && _baby!.photo!.isNotEmpty) {
      try {
        final imageData = _baby!.photo!.split(',').last;
        return Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
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
        print('Error loading baby photo: $e');
      }
    }
    
    // Foto por defecto
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
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
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Perfil del Bebé'),
          backgroundColor: const Color(0xFF6BA3E8),
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: CircularProgressIndicator(color: Color(0xFF6BA3E8)),
        ),
      );
    }

    if (_baby == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Perfil del Bebé'),
          backgroundColor: const Color(0xFF6BA3E8),
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text('Error al cargar el bebé'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Perfil del Bebé'),
        backgroundColor: const Color(0xFF6BA3E8),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditBabyScreen(baby: _baby!),
                ),
              );
              
              if (result == true) {
                _loadBabyData();
              }
            },
            icon: const Icon(Icons.edit),
            tooltip: 'Editar bebé',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadBabyData,
        color: const Color(0xFF6BA3E8),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // Header con información del bebé
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF6BA3E8), Color(0xFF5B93D8)],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      // Avatar
                      _buildBabyAvatar(),
                      const SizedBox(height: 16),
                      // Nombre
                      Text(
                        _baby!.name,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Edad
                      Text(
                        _baby!.getAgeFormatted(),
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Información del bebé
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Información',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildInfoRow(
                            icon: Icons.cake,
                            iconColor: const Color(0xFF6BA3E8),
                            label: 'Fecha de nacimiento',
                            value: _baby!.getFormattedBirthDate(),
                          ),
                          const SizedBox(height: 16),
                          _buildInfoRow(
                            icon: Icons.calendar_today,
                            iconColor: const Color(0xFF9C27B0),
                            label: 'Edad',
                            value: _baby!.getAgeFormatted(),
                          ),
                          const SizedBox(height: 16),
                          _buildInfoRow(
                            icon: Icons.event_note,
                            iconColor: const Color(0xFF4CAF50),
                            label: 'Registrado',
                            value: _baby!.getFormattedCreatedAt(),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Cuidadores
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Cuidadores',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        if (_isOwner)
                          TextButton.icon(
                            onPressed: _addCaregiver,
                            icon: const Icon(Icons.add, size: 20),
                            label: const Text('Añadir'),
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF6BA3E8),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Lista de cuidadores
                    ..._caregivers.map((caregiver) {
                      final isOwner = caregiver['role'] == 'owner';
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: const Color(0xFF6BA3E8).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.person,
                                color: Color(0xFF6BA3E8),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    caregiver['name'] ?? 'Sin nombre',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1A1A1A),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isOwner
                                              ? const Color(0xFF6BA3E8)
                                                  .withOpacity(0.1)
                                              : Colors.grey.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          isOwner ? 'Propietario' : 'Cuidador',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: isOwner
                                                ? const Color(0xFF6BA3E8)
                                                : Colors.grey.shade700,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            if (_isOwner && !isOwner)
                              IconButton(
                                onPressed: () => _removeCaregiver(
                                  caregiver['id'],
                                  caregiver['name'] ?? 'este cuidador',
                                ),
                                icon: const Icon(Icons.remove_circle_outline),
                                color: Colors.red,
                                tooltip: 'Eliminar cuidador',
                              ),
                          ],
                        ),
                      );
                    }),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}