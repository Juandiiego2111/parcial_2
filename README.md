# Parcial 2 — Flutter 🇨🇴

Aplicación Flutter con dos módulos integrados:
1. **Estadísticas de Accidentes de Tránsito en Tuluá** — consume el dataset público de Datos Abiertos Colombia, procesa los registros con un Isolate y visualiza 4 estadísticas con `fl_chart`.
2. **CRUD de Establecimientos** — consume la API REST del sistema de parqueadero con soporte de carga de logo (imagen).

**Autor:** Juan Diego Rodriguez Ortiz  
**Código estudiantil:** 230231020  
**GitHub:** [@Juandiiego2111](https://github.com/Juandiiego2111)  
**Repositorio:** https://github.com/Juandiiego2111/parcial_2

---

## APIs Utilizadas

### API 1 — Accidentes de Tránsito Tuluá (Datos Abiertos Colombia)

- **Base URL:** `https://www.datos.gov.co/resource/ezt8-5wyj.json`
- No requiere autenticación. Respuesta JSON directa.
- **Endpoint:** `GET ...ezt8-5wyj.json?$limit=100000`

| Campo | Descripción |
|---|---|
| `clase_de_accidente` | Choque, Atropello, Volcamiento, etc. |
| `gravedad_del_accidente` | Con muertos / Con heridos / Solo daños |
| `barrio_hecho` | Barrio donde ocurrió el accidente |
| `dia` | Día de la semana |
| `hora` | Hora del accidente |
| `area` | Urbana / Rural |
| `clase_de_vehiculo` | Tipo de vehículo involucrado |

**Ejemplo de respuesta JSON:**
```json
{
  "clase_de_accidente": "Choque",
  "gravedad_del_accidente": "Con heridos",
  "barrio_hecho": "CENTRO",
  "dia": "Lunes",
  "hora": "08:30",
  "area": "Urbana",
  "clase_de_vehiculo": "Automóvil"
}
```

### API 2 — Establecimientos (API Parqueadero)

- **Base URL:** `https://parking.visiontic.com.co/api`
- **Documentación:** https://parking.visiontic.com.co/api/documentation

| Método | Endpoint | Acción |
|---|---|---|
| GET | `/establecimientos` | Listar todos |
| GET | `/establecimientos/{id}` | Ver uno |
| POST | `/establecimientos` | Crear (multipart/form-data) |
| POST | `/establecimiento-update/{id}` | Editar (`_method=PUT`) |
| DELETE | `/establecimientos/{id}` | Eliminar |

**Ejemplo de respuesta JSON:**
```json
{
  "id": 1,
  "nombre": "Parqueadero Central",
  "nit": "900123456-7",
  "direccion": "Cra 5 # 10-20",
  "telefono": "3001234567",
  "logo": "storage/logos/logo.jpg"
}
```

---

## Future / async-await vs Isolate

**`Future` + `async/await`** es suficiente para operaciones de I/O (peticiones HTTP, archivos, base de datos) porque el hilo principal no se bloquea mientras espera la respuesta de la red.

**`Isolate`** (o `compute()`) es necesario cuando hay que procesar grandes volúmenes de datos **en memoria**, como clasificar, agregar o filtrar decenas de miles de registros. Ejecutar esa lógica en el hilo principal causaría congelamiento visible de la interfaz.

En este parcial se usó `compute(calcularEstadisticas, rawData)` para procesar hasta **100.000 registros** de accidentes fuera del hilo principal. El resultado se devuelve como `Map<String, dynamic>` y alimenta directamente las 4 gráficas. Las líneas de log confirman el procesamiento:

```
[Isolate] Iniciado — N registros recibidos
[Isolate] Completado en X ms
```

---

## Arquitectura y Estructura del Proyecto

```
lib/
├── core/constants/
│   └── api_constants.dart          # URLs base desde .env
├── models/
│   ├── accidente_model.dart         # fromJson / toJson
│   └── establecimiento_model.dart   # fromJson / toJson + logoUrl getter
├── isolates/
│   └── accidentes_isolate.dart      # calcularEstadisticas() — 4 stats
├── services/
│   ├── accidentes_service.dart      # GET ?$limit=100000 con Dio
│   └── establecimientos_service.dart# CRUD completo con Dio + multipart
├── views/
│   ├── dashboard/
│   │   └── dashboard_view.dart      # Home: totales + cards módulos
│   ├── accidentes/
│   │   └── estadisticas_view.dart   # 4 gráficas fl_chart
│   └── establecimientos/
│       ├── establecimientos_list_view.dart   # Lista + skeleton + FAB
│       ├── establecimiento_detail_view.dart  # Detalle + edit + delete
│       └── establecimiento_form_view.dart    # Crear / Editar
├── widgets/
│   └── skeleton_card.dart           # Skeletonizer reutilizable
├── app_router.dart                   # go_router
└── main.dart                         # dotenv + MaterialApp.router
```

### Paquetes utilizados

| Paquete | Versión | Uso |
|---|---|---|
| `dio` | ^5.4.0 | Peticiones HTTP + multipart/form-data |
| `go_router` | ^17.0.0 | Navegación declarativa con extra |
| `flutter_dotenv` | ^6.0.0 | Variables de entorno (.env) |
| `fl_chart` | ^0.68.0 | PieChart y BarChart |
| `skeletonizer` | ^2.0.0 | Efecto skeleton en carga |
| `image_picker` | ^1.0.7 | Selección de logo (galería / cámara) |

---

## Rutas implementadas con go_router

| Ruta | Pantalla | Parámetros |
|---|---|---|
| `/` | DashboardView | — |
| `/estadisticas` | EstadisticasView | — |
| `/establecimientos` | EstablecimientosListView | — |
| `/establecimientos/create` | EstablecimientoFormView | id: null |
| `/establecimientos/:id` | EstablecimientoDetailView | `id` (int) |
| `/establecimientos/:id/edit` | EstablecimientoFormView | `id` (int), `extra`: EstablecimientoModel |

Los objetos completos se pasan con `state.extra` para evitar peticiones HTTP redundantes en la pantalla de edición:

```dart
context.push('/establecimientos/${est.id}/edit', extra: est);
```

---

## Capturas de Pantalla

### Dashboard
> Totales de accidentes y establecimientos cargados en paralelo con `Future.wait()`. Skeleton mientras carga.

<!-- Insertar captura del Dashboard -->

### Estadísticas de Accidentes — 4 Gráficas
> PieChart de clase, BarChart de gravedad, BarChart top 5 barrios, BarChart por día.

<!-- Insertar captura de estadísticas -->

### Listado de Establecimientos
> ListView.builder con logo, nombre, NIT, dirección y teléfono. Skeleton + FAB.

<!-- Insertar captura del listado -->

### Formulario Crear / Editar
> Formulario con validación, selector de imagen (galería o cámara) y envío multipart.

<!-- Insertar captura del formulario -->

### Detalle y Eliminación
> Detalle completo con logo grande. Botones editar y eliminar con AlertDialog de confirmación.

<!-- Insertar captura del detalle -->

---

## Flujo de trabajo Git

```
main          ← rama estable (producción)
└── dev       ← rama de integración
    └── feature/parcial_flutter_final  ← desarrollo del parcial
```

1. Se creó `feature/parcial_flutter_final` a partir de `dev`
2. Commits atómicos con prefijos: `feat:`, `fix:`, `docs:`, `refactor:`
3. Pull Request de `feature/parcial_flutter_final` → `dev` con descripción y capturas
4. Merge a `dev` y posteriormente a `main`

---

## Instrucciones para ejecutar

```bash
# 1. Clonar el repositorio
git clone https://github.com/Juandiiego2111/parcial_2.git
cd parcial_2

# 2. Instalar dependencias
flutter pub get

# 3. Verificar el archivo .env en la raíz
# ACCIDENTES_BASE_URL=https://www.datos.gov.co/resource/ezt8-5wyj.json
# ESTABLECIMIENTOS_BASE_URL=https://parking.visiontic.com.co/api

# 4. Ejecutar
flutter run
```
