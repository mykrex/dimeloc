# Dimeloc – Sistema de Gestión de Tiendas con IA
---

## 📋 Descripción del Proyecto

Dimeloc es una aplicación móvil desarrollada para Arca Continental que revoluciona la gestión de tiendas de abarrotes (canal tradicional) mediante inteligencia artificial. La app permite a los colaboradores:

- Capturar datos cualitativos y contextuales durante sus visitas mensuales  
- Generar insights automáticos con Gemini IA  
- Estandarizar la recolección de información  
- Evaluar la viabilidad del desarrollo asistido por IA  
- Fortalecer la relación con clientes del canal tradicional  

---

## 🏢 Contexto Empresarial

Arca Continental atiende a miles de tiendas que usan la app Tuali para pedidos. Sin embargo, carecía de información cualitativa sobre la operación, necesidades y entorno de estas tiendas, lo que limitaba la generación de insights completos para la toma de decisiones.

---

## 🎯 Objetivos Principales

1. **Capturar información cualitativa y contextual** de puntos de venta  
2. **Generar insights útiles** mediante análisis con IA (Gemini)  
3. **Estandarizar la recolección de datos**  
4. **Evaluar la viabilidad** del desarrollo asistido por IA  
5. **Fortalecer la relación** con los tenderos del canal tradicional  

---

## ✨ Características Principales

### 🗺️ Mapa Interactivo
- Visualización de tiendas con logos personalizados (OXXO, 7-Eleven, HEB…)  
- Filtros por rendimiento: Excelentes, Buenas, Problemáticas  
- Búsqueda en tiempo real  
- Navegación directa a Apple Maps  

### 🏠 Dashboard Inteligente
- Insights de Gemini IA con recomendaciones personalizadas  
- Calendario de visitas pendientes  
- Resumen de tiendas por visitar  
- Métricas de rendimiento en tiempo real  

### 💬 Sistema de Feedback Bidireccional

#### Feedback del Colaborador
- Categorización automática (infraestructura, inventario, servicio…)  
- Niveles de urgencia configurables  
- Análisis automático con IA  

#### Feedback del Tendero
- Quejas, sugerencias y felicitaciones  
- Interfaz específica para la perspectiva del tendero  
- Seguimiento de incidentes  

### 📊 Panel de Administración
- Estadísticas en tiempo real con gráficos dinámicos  
- Filtrado avanzado por categorías de rendimiento  
- Vista consolidada de métricas clave  
- Identificación de tiendas problemáticas  

### 🏪 Detalles de Tienda
- Métricas: NPS, Fill Found Rate, Damage Rate, Out of Stock  
- Tiempo de resolución de quejas  
- Recomendaciones automáticas basadas en rendimiento  
- Historial de comentarios recientes  

### 🤖 Análisis con IA (Gemini)
- Generación automática de insights  
- Alertas inteligentes  
- Recomendaciones contextuales  
- Análisis de tendencias  

---

## 🏗️ Arquitectura Técnica

### 📱 Frontend – iOS (SwiftUI)

    dimeloc/
    ├── Views/
    │   ├── FeedbackListView.swift
    │   ├── TenderoFeedbackView.swift
    │   ├── AdminView.swift
    │   ├── MapView.swift
    │   └── TiendaDetailView.swift
    ├── Models/
    │   ├── Models.swift
    │   ├── AuthModels.swift
    │   └── APIResponses.swift
    ├── Services/
    │   ├── TiendasAPIClient.swift
    │   └── AuthAPIClient.swift
    ├── Managers/
    │   └── AuthManager.swift
    └── Assets.xcassets/
        ├── Logos de tiendas
        └── Iconografía personalizada

### 🌐 Backend Integration
- **API REST** en Node.js con Express  
- **Base de datos** MongoDB  
- **Gemini IA** para análisis y generación de insights  
- **Autenticación** JWT con roles diferenciados  

---

## 🔧 Tecnologías Utilizadas

- **SwiftUI 5.0**  
- **iOS 17.0+**  
- **CoreLocation & MapKit**  
- **Charts Framework**  
- **Combine**  
- **URLSession**  
- **Node.js & Express**  
- **MongoDB**  
- **Gemini IA**  

---

## 📦 Instalación y Configuración

### 📋 Requisitos
- Xcode 15.0+  
- iOS 17.0+  
- Cuenta de desarrollador Apple  

### ⚙️ Configuración Local

1. Clonar el repositorio  
   ```bash
   git clone https://github.com/tu-usuario/dimeloc-ios.git
   cd dimeloc-ios
   ```  
2. Abrir en Xcode  
   ```bash
   open dimeloc.xcodeproj
   ```  
3. Verificar que los assets (logos de tiendas) estén en `Assets.xcassets`  

### 🔧 Configuración de API

```swift
// APIConfig.swift
struct APIConfig {
    static let baseURL = "https://dimeloc-backend.onrender.com/api"
    static let timeout: TimeInterval = 30.0

    struct TestUsers {
        static let colaborador = TestUser(
            email: "colaborador@arcacontinental.mx",
            password: "password123",
            rol: "colaborador"
        )
    }
}
```

---

## 🧪 Testing y Validación

- Health Check – Verificación de conectividad con backend  
- Autenticación – Login y validación de tokens  
- CRUD Tiendas – Obtención y filtrado de tiendas  
- Feedback System – Envío y recepción de comentarios  
- IA Integration – Generación de insights con Gemini  

**Casos probados**:  
- Login exitoso  
- Visualización de mapa con 1000+ tiendas  
- Filtrado en tiempo real  
- Envío de feedback con análisis IA  
- Navegación fluida entre vistas  

---

## 📊 Métricas y KPIs

- **NPS (Net Promoter Score)**: 0–100  
- **Fill Found Rate**: Disponibilidad de productos  
- **Damage Rate**: % de productos dañados  
- **Out of Stock**: % de desabasto  
- **Resolution Time**: Tiempo de resolución de quejas  

---

## 📄 Licencia y Seguridad

Este proyecto es propiedad de Arca Continental (uso interno).  
- **Autenticación** JWT con roles  
- **HTTPS** en todas las comunicaciones  
- **Validación** de datos en frontend/backend  
- **Logs** de auditoría para acciones críticas  

---

## 📞 Contacto y Soporte
- **Nombre**: Maria Quetzali Ramirez Martinez
- **Email**: A01753959.mx

- **Nombre**: Maruca Cantu Valdes
- **Email**: A00834245.mx  
---

<div align="center">
  <strong>Desarrollado con ❤️ y 🤖 IA para Arca Continental</strong>  
  <em>"Conectando con el Punto de Venta a través de la Innovación"</em>
</div>
