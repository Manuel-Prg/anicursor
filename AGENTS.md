# ANI to XCursor — AGENTS.md

## Descripción

Aplicación de escritorio Linux construida con Flutter para convertir cursores animados de Windows (.ani) al formato XCursor de Linux, manteniendo animaciones y generando symlinks de aliases.

## Stack

- **Flutter** (Linux desktop)
- **Riverpod** (estado)
- **Go Router** (navegación)
- **file_picker** (selección de carpetas)
- **path_provider** (rutas del sistema)

## Arquitectura

Feature-first con separación en capas:

- `presentation/` → UI (páginas y widgets)
- `domain/` → modelos y casos de uso
- `data/` → repositorios

## Estructura

lib/
├── app/ # Router y App widget
├── features/
│ ├── home/ # Pantalla inicial con drag & drop
│ ├── converter/ # Lógica de conversión y provider
│ └── preview/ # Vista previa del tema generado
└── shared/ # Tema, widgets y utils compartidos

## Convenciones

- Providers en `presentation/nombre_provider.dart` dentro de cada feature
- Modelos inmutables con `copyWith`
- Streams para progreso de conversión
- Snake_case para archivos, PascalCase para clases

## Dependencias del sistema

Requiere tener instalado en el sistema:

- `imagemagick` (convert) — extracción de frames
- `xcursorgen` — generación de cursores Linux

## Flujo de conversión

1. Usuario selecciona carpeta con archivos `.ani`
2. `ConverterRepository.scanDirectory()` detecta cursores disponibles
3. `ConvertThemeUsecase.execute()` emite Stream de progreso
4. Por cada cursor: extrae frames → genera `.conf` → ejecuta `xcursorgen`
5. Crea symlinks de aliases
6. Instala en `~/.local/share/icons/`

## Mapa de cursores Windows → Linux

| Windows                  | Linux             | Aliases                       |
| ------------------------ | ----------------- | ----------------------------- |
| 01-Normal.ani            | left_ptr          | default, arrow                |
| 02-Link.ani              | hand2             | pointer, pointing_hand        |
| 03-Loading.ani           | watch             | wait, progress                |
| 04-Help.ani              | question_arrow    | help                          |
| 05-Text Select.ani       | xterm             | text, ibeam                   |
| 06-Handwriting.ani       | pencil            |                               |
| 07-Precision.ani         | cross             | crosshair                     |
| 08-Unavailable.ani       | not-allowed       | forbidden                     |
| 11-Vertical Resize.ani   | sb_v_double_arrow | n-resize, s-resize, ns-resize |
| 12-Horizontal Resize.ani | sb_h_double_arrow | e-resize, w-resize, ew-resize |
| 13-Diagonal Resize 1.ani | top_left_corner   | nw-resize, se-resize          |
| 14-Diagonal Resize 2.ani | top_right_corner  | ne-resize, sw-resize          |
| 15-Move.ani              | fleur             | move, all-scroll              |
| 16-Alternate Select.ani  | left_ptr_watch    | half-busy                     |

## Tareas pendientes

- [x] Drag & drop real con `desktop_drop`
- [x] Vista previa animada de cursores
- [x] Soporte para múltiples tamaños (24px, 32px, 48px)
- [x] Exportar tema como .zip
- [x] Soporte para cursores `.cur` (no animados)
- [x] Detección automática de nombres de archivo no estándar
