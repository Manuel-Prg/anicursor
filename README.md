# AniCursor 🐁✨

<p align="center">
  <img src="https://github.com/user-attachments/assets/16530704-59f7-4b9f-bb55-6ccd825cf46e" width="800"/>
</p>

**AniCursor** es una aplicación de escritorio para Linux que te permite convertir fácilmente cursores animados de Windows (`.ani` / `.cur`) al formato nativo de Linux (`XCursor`) en segundos.

Arrastra tu carpeta de cursores, conviértelos automáticamente y aplícalos a tu sistema sin configuraciones complicadas.

---

## ⚡ Demo rápido

<p align="center">
  <img src="https://github.com/user-attachments/assets/e80e50b9-990d-4259-944a-7379e66bcd11" width="800"/>
</p>

1. Arrastra una carpeta con cursores `.ani`
2. AniCursor los procesa automáticamente
3. Previsualiza el resultado
4. Instala el tema en tu sistema

---

## ¿Por qué AniCursor? 🤔

Convertir cursores de Windows a Linux siempre ha sido un proceso manual, tedioso y propenso a errores.

AniCursor automatiza todo el proceso:
- Extrae frames automáticamente  
- Genera configuraciones compatibles  
- Aplica el tema al sistema  

Todo en una interfaz moderna y simple.

---

## Características 🚀

- 🎨 Interfaz moderna (Material 3, modo claro/oscuro)
- 🖱️ Drag & Drop para conversión rápida
- 👀 Vista previa animada en tiempo real
- 📦 Exportación lista para compartir (.zip)
- ⚙️ Instalación local o global (pkexec)
- 🧠 Auto-mapeo de cursores Windows → Linux
- 🧪 Validación automática post-conversión

---

## 🖼️ Capturas

### Interfaz principal
<img src="https://github.com/user-attachments/assets/06a985be-e6cc-4304-8571-b88c4423e2bf" width="800"/>

### Vista previa animada
<img src="https://github.com/user-attachments/assets/e0692b3b-96ec-481f-8a6b-47e70ba4e131" width="800"/>

### Proceso de conversión
<img src="https://github.com/user-attachments/assets/007e777e-a0aa-4dec-8a8c-0616b6a12e6d" width="800"/>

### Cursores instalados
<img src="https://github.com/user-attachments/assets/1a60354f-6f89-46be-8fce-c03e1e5a9f33" width="800"/>

---

## Requisitos y Dependencias ⚙️

Asegúrate de tener instaladas estas herramientas:

- `imagemagick` (para extraer frames)
- `xcursorgen` (generador de cursores X11)

En Debian/Ubuntu:

```bash
sudo apt install imagemagick x11-apps
```
*(Nota: En distribuciones como Arch Linux / Fedora el paquete de generador de X11 puede variar sus nombres, usualmente bajo `xorg-xcursorgen`).*

---

## Instalación 🛠️

1. Descarga la última versión desde [Releases](https://github.com/Manuel-Prg/anicursor/releases)
2. Da permisos de ejecución:
   ```bash
   chmod +x anicursor
3. Ejecuta
   ```bash
   ./anicursor
   
---
Hecho con ❤️ por **manuelprz**  
Si te gusta el proyecto, dale ⭐ en GitHub**
