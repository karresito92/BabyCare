# 🍼 BabyCare - Aplicación de Gestión y Seguimiento Infantil

![BabyCare Banner](https://img.shields.io/badge/Flutter-3.35.4-blue?logo=flutter)
![FastAPI](https://img.shields.io/badge/FastAPI-0.115.0-green?logo=fastapi)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-17-blue?logo=postgresql)
![License](https://img.shields.io/badge/License-MIT-yellow)

**BabyCare** es una aplicación web multiplataforma diseñada para facilitar el seguimiento y registro del cuidado diario de bebés durante sus primeros años de vida.

🔗 **[Ver aplicación en vivo](https://babycare-8hlu.onrender.com)**

---

## 📋 Descripción

Aplicación completa de gestión infantil que permite a padres y cuidadores:

- ✅ Registrar actividades diarias (alimentación, sueño, pañales, salud)
- ✅ Sistema multi-cuidador con sincronización en tiempo real
- ✅ Análisis inteligente con IA para detectar patrones
- ✅ Generación de informes médicos profesionales en PDF
- ✅ Estadísticas visuales y gráficas interactivas
- ✅ Predicciones con Machine Learning

---

## 🚀 Tecnologías

### Frontend
- **Flutter 3.35.4** - Framework multiplataforma
- **Dart** - Lenguaje de programación
- **Google Fonts** - Tipografía premium (Poppins/Inter)
- **Flutter Secure Storage** - Almacenamiento seguro de tokens

### Backend
- **FastAPI** - Framework web de alto rendimiento
- **Python 3.12** - Lenguaje del servidor
- **PostgreSQL 17** - Base de datos relacional
- **SQLAlchemy 2.0** - ORM para gestión de BD
- **JWT + Argon2** - Autenticación segura
- **ReportLab** - Generación de PDFs
- **NumPy** - Análisis estadístico y ML

### Despliegue
- **Render** - Hosting del backend y frontend
- **Supabase** - Base de datos PostgreSQL gestionada
- **Docker** - Contenedorización
- **UptimeRobot** - Monitorización 24/7

---

## 🎯 Funcionalidades Principales

### 1. Registro de Actividades
- 🍼 **Alimentación:** Tipo (biberón/pecho), cantidad, notas
- 😴 **Sueño:** Duración, horarios, calidad
- 🧷 **Pañales:** Tipo (mojado/sucio/ambos)
- 🏥 **Salud:** Temperatura, medicamentos, consultas

### 2. Sistema Multi-Cuidador
- Múltiples usuarios pueden acceder al mismo bebé
- Sincronización en tiempo real
- Control de permisos (propietario/cuidador)

### 3. Insights con Inteligencia Artificial
- Detección automática de patrones de comportamiento
- Predicción de próxima toma con regresión lineal
- Alertas inteligentes (tiempo sin comer, anomalías)
- Clasificación de calidad del sueño
- Recomendaciones personalizadas

### 4. Estadísticas y Visualización
- Gráficas de alimentación y sueño
- Resúmenes estadísticos con promedios
- Filtros por período (hoy/semana/mes)

### 5. Informes Médicos PDF
- Diseño profesional con tablas y colores
- Resumen estadístico completo
- Detalle de todas las actividades
- Observaciones importantes destacadas
- Listo para presentar al pediatra

---

## 📦 Instalación Local

### Requisitos Previos
- Python 3.12+
- Flutter 3.35.4+
- PostgreSQL 17+
- Git

### Backend
```bash
# Clonar repositorio
git clone https://github.com/karresito92/BabyCare.git
cd BabyCare

# Crear entorno virtual
python -m venv venv
venv\Scripts\activate  # Windows
source venv/bin/activate  # Linux/Mac

# Instalar dependencias
pip install -r requirements.txt

# Configurar variables de entorno
cp .env.example .env
# Editar .env con tus credenciales

# Iniciar base de datos con Docker
docker-compose up -d

# Ejecutar servidor
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

### Frontend
```bash
# Navegar a carpeta de Flutter
cd babycare_flutter_app

# Instalar dependencias
flutter pub get

# Ejecutar en Chrome
flutter run -d chrome

# O compilar para producción
flutter build web --release
```

---

## 🗄️ Estructura del Proyecto
```
babycare/
├── app/
│   ├── main.py                 # Punto de entrada FastAPI
│   ├── database.py             # Configuración de BD
│   ├── models/                 # Modelos SQLAlchemy
│   │   ├── user.py
│   │   ├── baby.py
│   │   ├── activity.py
│   │   └── user_baby.py
│   ├── schemas/                # Schemas Pydantic
│   ├── routers/                # Endpoints de la API
│   │   ├── auth.py
│   │   ├── babies.py
│   │   ├── activities.py
│   │   └── caregivers.py
│   ├── services/               # Lógica de negocio
│   │   ├── pdf_generator.py
│   │   ├── insights_service.py
│   │   └── ml_service.py
│   └── core/                   # Configuración
│       ├── config.py
│       └── security.py
├── babycare_flutter_app/
│   ├── lib/
│   │   ├── main.dart
│   │   ├── models/             # Modelos Dart
│   │   ├── services/           # API Service
│   │   ├── screens/            # Pantallas de la app
│   │   └── utils/              # Utilidades
│   └── pubspec.yaml
├── frontend_dist/              # Build de Flutter para producción
├── docker-compose.yml
├── requirements.txt
└── README.md
```

---

## 📊 Modelo de Base de Datos
```
users ──┬── user_babies ──┬── babies
        │                  │
        │                  └── activities
        │
        └── activities (FK: user_id)
```

**Tablas principales:**
- `users` - Usuarios registrados
- `babies` - Información de bebés
- `user_babies` - Relación N:M (multi-cuidador)
- `activities` - Registros de actividades

---

## 🔐 Seguridad

- ✅ HTTPS obligatorio con certificado SSL/TLS
- ✅ Contraseñas hasheadas con Argon2
- ✅ Tokens JWT con expiración de 30 días
- ✅ Validación de datos con Pydantic
- ✅ SQL parametrizado (prevención de inyecciones)
- ✅ Control de acceso basado en roles

---

## 🧪 Testing
```bash
# Ejecutar tests del backend
pytest

# Ejecutar tests de Flutter
flutter test
```

---

## 📱 Capturas de Pantalla

*[Aquí puedes añadir capturas de pantalla de la aplicación]*

---

## 🤝 Contribuciones

Las contribuciones son bienvenidas. Por favor:

1. Fork el proyecto
2. Crea tu feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la branch (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

---

## 📝 Licencia

Este proyecto es un Trabajo Final de Grado (TFG) del Ciclo Formativo de Grado Superior en Desarrollo de Aplicaciones Multiplataforma.

**Autor:** Adrián Carretero Gutiérrez  
**Institución:** IES Ágora  
**Año:** 2025

---

## 📧 Contacto

- **Email:** acarretero08@gmail.com
- **GitHub:** [@karresito92](https://github.com/karresito92)
- **Aplicación:** [https://babycare-8hlu.onrender.com](https://babycare-8hlu.onrender.com)
