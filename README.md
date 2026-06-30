# AniCursor 🐁✨

<p align="center">
  <img width="720" height="454" alt="video_1" src="https://github.com/user-attachments/assets/81f2de29-085a-4aac-b3fc-cc3df372c956" />
</p>

**AniCursor** es una aplicación de escritorio para Linux que te permite convertir fácilmente cursores animados de Windows (`.ani` / `.cur`) al formato nativo de Linux (`XCursor`) en segundos.

Arrastra tu carpeta de cursores, conviértelos automáticamente y aplícalos a tu sistema sin configuraciones complicadas.

---

## ⚡ Demo rápido

<p align="center">
  <img width="720" height="435" alt="video_2" src="https://github.com/user-attachments/assets/46c12a3d-d35a-4623-83d3-30f8a716096b" />
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
<img width="1920" height="1080" alt="inicio" src="https://github.com/user-attachments/assets/f92eddc9-8fec-468b-82c7-a0f252b8a479" />

### Vista previa animada
<img src="https://github.com/user-attachments/assets/e0692b3b-96ec-481f-8a6b-47e70ba4e131" width="800"/>

### Proceso de conversión
<img width="1920" height="1080" alt="conversor" src="https://github.com/user-attachments/assets/17baac7e-4649-4efc-b1e2-5f6b77e81472" />

### Cursores instalados
<img width="1920" height="1080" alt="visualizador" src="https://github.com/user-attachments/assets/ea197a00-a63e-4265-bab6-fb3a46bac418" />

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
