# SipTrack 🍹

App iOS para registrar y hacer seguimiento de tus consumiciones de bebidas.

## Funcionalidades

### Pantalla Calendario
- Fecha actual del día
- Leyenda de colores: Cubatas (rojo), Chupitos (azul), Baja graduación (amarillo)
- Calendario mensual con puntitos de colores bajo cada día según lo consumido
- Al tocar un día: muestra las consumiciones con hora y tamaño
- Botón de editar/eliminar registros

### Pantalla Registro
- 3 botones grandes por categoría: **CUBATAS**, **CHUPITOS**, **BAJA º**
- Cada categoría tiene su lista scrollable de bebidas personalizadas
- Crear bebidas con nombre + foto (cámara o galería)
- Modo editar: marcar favoritos (corazón) y eliminar bebidas (X)
- Los favoritos aparecen primero
- Al tocar una bebida: seleccionar tamaño (Grande / Normal / Pequeño)
- Se guarda automáticamente: bebida, tamaño, fecha y hora

## Requisitos

- **Xcode 15+**
- **iOS 17+**
- **Cuenta de Firebase** (gratuita)

## Configuración

### 1. Abrir en Xcode

1. Abre Xcode
2. Selecciona **File > New > Project**
3. Elige **App** (iOS) y ponle de nombre `SipTrack`
4. Selecciona **SwiftUI** como interfaz y **Swift** como lenguaje
5. Crea el proyecto
6. **Elimina** los archivos por defecto (`ContentView.swift`, `SipTrackApp.swift` generados)
7. **Arrastra** la carpeta `DrinkTracker/` de este repo al proyecto en Xcode (asegúrate de marcar "Copy items if needed" y "Create groups")

### 2. Añadir Firebase SDK

1. En Xcode, ve a **File > Add Package Dependencies**
2. Pega esta URL: `https://github.com/firebase/firebase-ios-sdk`
3. Selecciona la versión más reciente
4. Añade estos productos:
   - `FirebaseCore`
   - `FirebaseFirestore`
   - `FirebaseStorage`

### 3. Configurar Firebase

1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Crea un nuevo proyecto (o usa uno existente)
3. Añade una app iOS con el Bundle ID de tu proyecto (ej: `com.tuNombre.SipTrack`)
4. Descarga el archivo `GoogleService-Info.plist`
5. Arrastra `GoogleService-Info.plist` al proyecto en Xcode (al nivel raíz del target)

### 4. Configurar Firestore

1. En Firebase Console, ve a **Firestore Database**
2. Crea una base de datos en **modo de prueba** (para desarrollo)
3. La app creará automáticamente las colecciones necesarias:
   - `drinks` - Bebidas personalizadas
   - `records` - Registros de consumiciones

### 5. Configurar Firebase Storage

1. En Firebase Console, ve a **Storage**
2. Actívalo en **modo de prueba**
3. Se usará para almacenar las fotos de las bebidas

### 6. Compilar y ejecutar

1. Selecciona un simulador o tu dispositivo
2. Pulsa **Cmd + R** para compilar y ejecutar

## Estructura del proyecto

```
SipTrack/
├── SipTrackApp.swift          # Entry point + Firebase init
├── Models/
│   ├── DrinkCategory.swift        # Categorías (cubata, chupito, baja graduación)
│   ├── Drink.swift                # Modelo de bebida
│   └── DrinkRecord.swift          # Modelo de registro de consumición
├── ViewModels/
│   ├── DrinksViewModel.swift      # Lógica de bebidas (CRUD, favoritos)
│   └── CalendarViewModel.swift    # Lógica del calendario y registros
├── Views/
│   ├── MainTabView.swift          # TabView principal
│   ├── Calendar/
│   │   └── CalendarTabView.swift  # Pantalla del calendario
│   ├── DrinkSelection/
│   │   ├── DrinkCategorySelectionView.swift  # 3 botones de categorías
│   │   ├── DrinkListView.swift              # Lista de bebidas
│   │   ├── DrinkCardView.swift              # Tarjeta de bebida
│   │   ├── AddDrinkView.swift               # Formulario nueva bebida
│   │   └── SizeSelectionView.swift          # Selector de tamaño
│   └── Components/
│       └── ImagePicker.swift      # Selector de imagen (cámara/galería)
└── Services/
    └── FirestoreService.swift     # Servicio Firebase (Firestore + Storage)
```

## Tecnologías

- **SwiftUI** - Interfaz declarativa
- **Firebase Firestore** - Base de datos en la nube
- **Firebase Storage** - Almacenamiento de imágenes
- **MVVM** - Arquitectura Model-View-ViewModel
- **Swift Concurrency** - async/await
