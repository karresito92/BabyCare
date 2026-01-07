import 'dart:convert';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/auth_storage.dart';
import '../../models/user.dart';
import 'edit_profile_screen.dart';
import 'change_password_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _apiService = ApiService();
  User? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userData = await _apiService.getCurrentUser();
      _user = User.fromJson(userData);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar perfil: ${e.toString()}'),
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

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final authStorage = AuthStorage();
      await authStorage.deleteToken();
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  Future<void> _navigateToEditProfile() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditProfileScreen(user: _user!)),
    );

    if (result == true) {
      _loadUserProfile();
    }
  }

  Future<void> _navigateToChangePassword() async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ChangePasswordScreen()),
    );
  }

  Widget _buildProfileAvatar() {
    if (_user?.profilePicture != null && _user!.profilePicture!.isNotEmpty) {
      try {
        final imageData = _user!.profilePicture!.split(',').last;
        return Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
              image: MemoryImage(base64Decode(imageData)),
              fit: BoxFit.cover,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 5),
              ),
            ],
          ),
        );
      } catch (e) {
        print('Error loading profile picture: $e');
      }
    }
    
    // Avatar por defecto
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: const Icon(
        Icons.person,
        size: 50,
        color: Color(0xFF6BA3E8),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF6BA3E8)),
              )
            : SingleChildScrollView(
                child: Column(
                  children: [
                    // Header
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
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            // Botón volver
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () => Navigator.pop(context),
                                  icon: const Icon(
                                    Icons.arrow_back,
                                    color: Colors.white,
                                  ),
                                ),
                                const Spacer(),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // Avatar
                            _buildProfileAvatar(),

                            const SizedBox(height: 16),

                            // Nombre
                            Text(
                              _user?.name ?? 'Usuario',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),

                            const SizedBox(height: 8),

                            // Email
                            Text(
                              _user?.email ?? '',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),

                            const SizedBox(height: 30),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Opciones
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          _buildOptionCard(
                            icon: Icons.edit,
                            iconColor: const Color(0xFF6BA3E8),
                            title: 'Editar perfil',
                            subtitle: 'Actualiza tu nombre y foto',
                            onTap: _navigateToEditProfile,
                          ),

                          const SizedBox(height: 12),

                          _buildOptionCard(
                            icon: Icons.lock,
                            iconColor: const Color(0xFF9C27B0),
                            title: 'Cambiar contraseña',
                            subtitle: 'Actualiza tu contraseña',
                            onTap: _navigateToChangePassword,
                          ),

                          const SizedBox(height: 12),

                          _buildOptionCard(
                            icon: Icons.logout,
                            iconColor: Colors.red,
                            title: 'Cerrar sesión',
                            subtitle: 'Salir de la aplicación',
                            onTap: _logout,
                          ),

                          const SizedBox(height: 30),

                          // Versión de la app
                          Text(
                            'BabyCare v1.0.0',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                          ),

                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildOptionCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
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
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}