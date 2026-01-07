import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F7FC),
      bottomNavigationBar: _bottomBar(),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 25),

                  /// TEXTOS DEL HEADER
                  const Text(
                    "BabyCare",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1C1C1C),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Bienvenido de vuelta",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),

                  const SizedBox(height: 15),

                  /// CARD AZUL PRINCIPAL
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xff62A8FF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Container(
                          height: 55,
                          width: 55,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.30),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Image.asset(
                              "assets/icons/baby_icon.png",
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        const SizedBox(width: 18),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Sofía Martínez",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 3),
                            Text(
                              "8 meses · 7.2 kg",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  /// RESUMEN DE HOY
                  const Text(
                    "Resumen de hoy",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 15),

                  Row(
                    children: [
                      Expanded(
                        child: _summaryCard(
                          icon: Icons.local_drink,
                          iconColor: Color(0xff3B82F6),
                          title: "Alimentación",
                          value: "6 veces",
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _summaryCard(
                          icon: Icons.nights_stay,
                          iconColor: Color(0xffA855F7),
                          title: "Sueño",
                          value: "8.5 hrs",
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        child: _summaryCard(
                          icon: Icons.baby_changing_station,
                          iconColor: Color(0xff22C55E),
                          title: "Pañales",
                          value: "5 cambios",
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _summaryCard(
                          icon: Icons.calendar_today,
                          iconColor: Color(0xffEF4444),
                          title: "Próxima cita",
                          value: "15 Nov",
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  /// ACCIONES RÁPIDAS
                  const Text(
                    "Acciones rápidas",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 15),

                  Row(
                    children: [
                      Expanded(
                        child: _quickCard(
                          icon: Icons.local_drink,
                          iconColor: Color(0xff3B82F6),
                          title: "Alimentación",
                          subtitle: "2h ago",
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _quickCard(
                          icon: Icons.nights_stay,
                          iconColor: Color(0xffA855F7),
                          title: "Sueño",
                          subtitle: "4h ago",
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        child: _quickCard(
                          icon: Icons.baby_changing_station,
                          iconColor: Color(0xff22C55E),
                          title: "Pañal",
                          subtitle: "2h ago",
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _quickCard(
                          icon: Icons.favorite,
                          iconColor: Color(0xffEF4444),
                          title: "Salud",
                          subtitle: "-",
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),

            /// CAMPANA EXACTAMENTE POSICIONADA
            Positioned(
              right: 5,
              top: 10,
              child: IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.notifications_none,
                  color: Colors.grey,
                  size: 26,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -----------------------------------------
  // ---------- WIDGETS AUXILIARES -----------
  // -----------------------------------------

  Widget _summaryCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.05),
            blurRadius: 6,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 28, color: iconColor),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.05),
            blurRadius: 6,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 28, color: iconColor),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black38,
            ),
          ),
        ],
      ),
    );
  }

  // -----------------------------------------
  // -------------- BOTTOM BAR ----------------
  // -----------------------------------------

  Widget _bottomBar() {
    return BottomNavigationBar(
      backgroundColor: Colors.white,
      selectedItemColor: const Color(0xff3B82F6),
      unselectedItemColor: Colors.grey,
      currentIndex: 0,
      elevation: 8,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: "Inicio",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.list_alt),
          label: "Actividades",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart),
          label: "Estadísticas",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: "Perfil",
        ),
      ],
    );
  }
}
