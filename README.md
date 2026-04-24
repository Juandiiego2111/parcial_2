# 🚦 parcial_2 · Flutter

**Autor:** Juan Diego Rodriguez Ortiz · `230231020` · [@Juandiiego2111](https://github.com/Juandiiego2111)

Proyecto Flutter de parcial que conecta dos fuentes de datos reales en una sola app:

- Descarga y analiza miles de registros de accidentes de tránsito en Tuluá usando un **Isolate** para no bloquear la UI, luego los presenta como 4 gráficas interactivas.
- Gestiona establecimientos de parqueadero con un **CRUD completo** que incluye carga de imagen desde galería o cámara.

---

## 🗂 Contenido

1. [Módulos de la app](#módulos-de-la-app)
2. [Fuentes de datos](#fuentes-de-datos)
3. [Por qué compute() y no solo async/await](#por-qué-compute-y-no-solo-asyncawait)
4. [Organización del código](#organización-del-código)
5. [Navegación con go_router](#navegación-con-go_router)
6. [Capturas](#capturas)
7. [Ramas y commits](#ramas-y-commits)
8. [Correr el proyecto](#correr-el-proyecto)

---

## Módulos de la app

### 📊 Módulo 1 — Estadísticas de Accidentes

Hace un GET con `$limit=100000`, pasa todos los registros a `compute()` para procesarlos fuera del hilo principal y renderiza cuatro gráficas con `fl_chart`:

| # | Estadística | Tipo de gráfica |
|---|---|---|
| 1 | Distribución por clase de accidente | `PieChart` |
| 2 | Distribución por gravedad | `BarChart` |
| 3 | Top 5 barrios con más accidentes | `BarChart` |
| 4 | Accidentes por día de la semana | `BarChart` |

Mientras cargan los datos aparece un skeleton animado. Si falla la petición se muestra un mensaje con botón **Reintentar**.

---

### 🏢 Módulo 2 — Gestión de Establecimientos

CRUD completo sobre la API Parqueadero:

| Operación | Detalle |
|---|---|
| Listar | `ListView.builder` con logo, nombre, NIT, dirección y teléfono |
| Ver detalle | Logo grande + campos en tarjetas con iconos |
| Crear | Formulario validado + selector de imagen (galería o cámara) |
| Editar | Misma pantalla del formulario, precargada con los datos del ítem |
| Eliminar | Botón en el detalle con `AlertDialog` de confirmación |

El update usa **method spoofing de Laravel**: se hace `POST` a `/establecimiento-update/{id}` incluyendo el campo `_method: PUT` en el `FormData`.

---

## Fuentes de datos

### Dataset — Accidentes Tuluá

```
GET https://www.datos.gov.co/resource/ezt8-5wyj.json?$limit=100000
```

Sin autenticación. Devuelve un array JSON con un registro por accidente.

**Campos usados:**

```json
{
  "clase_de_accidente":    "Choque",
  "gravedad_del_accidente":"Con heridos",
  "barrio_hecho":          "CENTRO",
  "dia":                   "Viernes",
  "hora":                  "14:30",
  "area":                  "Urbana",
  "clase_de_vehiculo":     "Automóvil"
}
```

---

### API Parqueadero — Establecimientos

```
Base: https://parking.visiontic.com.co/api
Docs: https://parking.visiontic.com.co/api/documentation
```

| Verbo HTTP | Ruta | Qué hace |
|---|---|---|
| `GET` | `/establecimientos` | Lista todos |
| `GET` | `/establecimientos/{id}` | Trae uno por ID |
| `POST` | `/establecimientos` | Crea uno nuevo |
| `POST` | `/establecimiento-update/{id}` | Edita (con `_method=PUT`) |
| `DELETE` | `/establecimientos/{id}` | Elimina |

**Respuesta típica:**

```json
{
  "id": 3,
  "nombre": "Parqueadero Norte",
  "nit": "900456789-1",
  "direccion": "Av. 4 Norte # 12-05",
  "telefono": "3156789012",
  "logo": "/storage/logos/norte.jpg"
}
```

El campo `logo` es una ruta relativa; el modelo lo convierte a URL absoluta con el getter `logoUrl`.

---

## Por qué `compute()` y no solo `async/await`

`async/await` resuelve el problema de **esperar** sin bloquear: la UI queda libre mientras se hace una petición HTTP, porque quien "trabaja" es la red, no Dart.

El problema aparece cuando hay que **procesar** lo que llegó. Con 100.000 registros, recorrer la lista, normalizar strings, contar frecuencias y ordenar resultados es trabajo puro de CPU que sí ocupa el hilo principal. Eso produce frames perdidos y la interfaz se congela.

`compute(calcularEstadisticas, rawData)` delega esa función a un Isolate —un hilo separado con su propio heap— y devuelve el resultado cuando termina. La UI sigue funcionando con normalidad durante todo el proceso.

En consola se puede ver cuándo inicia y cuánto tarda:

```
[Isolate] Iniciado — 8542 registros recibidos
[Isolate] Completado en 287 ms
```

> `compute()` de `flutter/foundation.dart` es equivalente a `Isolate.run()` y funciona desde Dart 2.19 / Flutter 3 en adelante.

---

## Organización del código

```
lib/
│
├── main.dart                               # Carga .env y monta MaterialApp.router
├── app_router.dart                         # Todas las rutas declaradas con go_router
│
├── core/
│   └── constants/api_constants.dart        # Lee las URLs desde dotenv
│
├── models/
│   ├── accidente_model.dart                # fromJson · toJson · toRawMap
│   └── establecimiento_model.dart          # fromJson · toJson · getter logoUrl
│
├── isolates/
│   └── accidentes_isolate.dart             # calcularEstadisticas() — función pura
│
├── services/
│   ├── accidentes_service.dart             # fetchAll() con Dio + $limit=100000
│   └── establecimientos_service.dart       # getAll · getById · create · update · delete
│
├── views/
│   ├── dashboard/
│   │   └── dashboard_view.dart             # Home: totales en paralelo + cards
│   ├── accidentes/
│   │   └── estadisticas_view.dart          # 4 gráficas + skeleton + error
│   └── establecimientos/
│       ├── establecimientos_list_view.dart  # Lista + skeleton + FAB
│       ├── establecimiento_detail_view.dart # Detalle + editar + eliminar
│       └── establecimiento_form_view.dart   # Crear / editar con image_picker
│
└── widgets/
    └── skeleton_card.dart                  # Skeletonizer reutilizable
```

### Dependencias

| Paquete | Versión | Para qué se usa |
|---|---|---|
| `dio` | ^5.4.0 | HTTP + `FormData` multipart |
| `go_router` | ^17.0.0 | Rutas declarativas con `extra` |
| `flutter_dotenv` | ^6.0.0 | URLs en `.env` |
| `fl_chart` | ^0.68.0 | `PieChart` y `BarChart` |
| `skeletonizer` | ^2.0.0 | Skeleton mientras carga |
| `image_picker` | ^1.0.7 | Logo desde galería o cámara |

`.env` declarado como asset en `pubspec.yaml` y cargado antes de `runApp()`:

```dart
await dotenv.load(fileName: '.env');
```

---

## Navegación con go_router

Definidas en `lib/app_router.dart`. Las rutas estáticas van antes que las dinámicas para que `go_router` no las confunda.

| Path | Pantalla | Parámetros |
|---|---|---|
| `/` | `DashboardView` | — |
| `/estadisticas` | `EstadisticasView` | — |
| `/establecimientos` | `EstablecimientosListView` | — |
| `/establecimientos/create` | `EstablecimientoFormView` | `id: null` |
| `/establecimientos/:id` | `EstablecimientoDetailView` | `id` → path param |
| `/establecimientos/:id/edit` | `EstablecimientoFormView` | `id` → path param · modelo → `extra` |

El objeto `EstablecimientoModel` se pasa completo con `extra` al editar para evitar una segunda petición al servidor:

```dart
// Enviar
context.push('/establecimientos/${widget.id}/edit', extra: est);

// Recibir en el router
final establecimiento = state.extra as EstablecimientoModel?;
```

---

## Capturas

### Dashboard
> Totales de accidentes y establecimientos cargados con `Future.wait()`. Cards de acceso a cada módulo.

<img width="391" height="820" alt="image" src="https://github.com/user-attachments/assets/a566e78a-2606-4357-b289-82afddb05607" />

### Estadísticas — 4 gráficas
> PieChart de clase · BarChart de gravedad · BarChart top barrios · BarChart por día.

<img width="508" height="746" alt="image" src="https://github.com/user-attachments/assets/7dc46fd9-76a5-4370-819a-fab043241a5a" />

### Listado de establecimientos
> `ListView.builder` con logo en `CircleAvatar`, nombre, NIT, dirección y teléfono.

<img width="410" height="914" alt="image" src="https://github.com/user-attachments/assets/69d09e89-c1b4-4159-9eab-044c4ddb7d19" />

### Formulario crear / editar
> Campos validados + selector de imagen con botones Galería y Cámara.

<img width="326" height="627" alt="image" src="https://github.com/user-attachments/assets/2db06149-3fe3-44a2-987a-7dc053485410" />
<img width="345" height="621" alt="image" src="https://github.com/user-attachments/assets/7d111cb0-9d1f-4334-ac7b-e2c115c3f61c" />

### Detalle + eliminación
> Logo grande · campos en tarjetas · `AlertDialog` de confirmación al eliminar.

<img width="391" height="836" alt="image" src="https://github.com/user-attachments/assets/ed55c1de-7a1e-45bf-b709-fcd5de1167ef" />

---

## Ramas y commits

```
main                          ← producción, solo merges revisados
└── dev                       ← integración
    └── feature/parcial_flutter_final   ← todo el desarrollo
```

Prefijos de commit usados: `feat:` `fix:` `docs:` `refactor:` `chore:`

Flujo seguido:
1. Desarrollo en `feature/parcial_flutter_final`
2. PR hacia `dev` con descripción y capturas de evidencia
3. Merge a `dev` tras revisión
4. Merge final a `main`

---

## Correr el proyecto

```bash
git clone https://github.com/Juandiiego2111/parcial_2.git
cd parcial_2
flutter pub get
flutter run
```

Verificar que se tiene Flutter ≥ 3.0 / Dart ≥ 2.19:

```bash
flutter --version
```
