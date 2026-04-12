# AniCursor 🐁✨

**AniCursor** es una elegante aplicación de escritorio para Linux construida con *Flutter*, diseñada para deconstruir, exportar y convertir fácilmente paquetes de cursores animados de Windows (`.ani` o `.cur`) al formato nativo `XCursor` compatible con entornos de escritorio en Linux (GNOME, Plasma, XFCE).

---

## Características Principales 🚀

- **Interfaz Moderna y Fluida**: Creada con componentes Material 3. Soporta temas Claro, Oscuro e integración de colores de contraste dinámico.
- **Soporte Drag & Drop**: Simplemente arrastra y suelta el directorio de cursores, la herramienta procesará recursivamente la carga.
- **Personalización de Destino**: Selecciona los tamaños de cursor resultantes que necesites (ej. 24, 32, 48px), ajusta el delay predeterminado o elige una ruta personalizada de compilación.
- **Vista Previa Animada**: Revisa el muestreo animado de los cursores obtenidos en tiempo real antes de instalar.
- **Exportación en un Clic**: Extrae tus resultados empaquetados en un archivo `.zip` perfecto para compartir en *GNOME-Look* o *Pling*.
- **Instalación de Raíz y Sandboxing**: Posibilidad de instalar localmente o globalmente (`pkexec`), y una herramienta integrada para otorgar permisos automáticos de visualización a sistemas aislados como **Flatpak**.

---

## Requisitos y Dependencias ⚙️

Como el motor detrás de la app funciona de la mano del sistema operativo nativo, debes asegurarte de tener instaladas las siguientes herramientas clásicas en Linux:

- `imagemagick` (usamos el comando `convert` para extraer los frames)
- `xcursorgen` (compilador nativo de iconos del protocolo X11)

Si estás usando sistemas Debian/Ubuntu o derivados:
```bash
sudo apt install imagemagick x11-apps
```
*(Nota: En distribuciones como Arch Linux / Fedora el paquete de generador de X11 puede variar sus nombres, usualmente bajo `xorg-xcursorgen`).*

---

## Descarga e Instalación 🛠️

**AniCursor** se distribuye de manera sencilla y portátil.

1. Navega a la pestaña de **[Releases](https://github.com/Manuel-Prg/anicursor/releases)** en GitHub.
2. Descarga la última versión del archivo (usualmente un `.zip` o archivo ejecutable con las librerías integradas).
3. Una vez extraído, dale permisos de ejecución al binario desde tu gestor de archivos o en la terminal:
   ```bash
   chmod +x anicursor
   ```
4. ¡Y listo! Ya puedes abrir la aplicación con doble clic o ejecutándola directamente:
   ```bash
   ./anicursor
   ```

*(Nota: Si como desarrollador deseas compilar la aplicación tú mismo desde el código fuente, asegúrate de tener entornos de Flutter activados e instalar las librerías de audio ejecutando `sudo apt install libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev` antes de correr `flutter build linux`).*

---

## Motivación 💡

Las grandes bibliotecas históricas de cursores hermosos para ratón están hechas bajo entornos Windows en archivos RIFF (`.ani`). Llevarlos a Linux requería mucho tiempo dividiendo frames a mano e ideando un archivo `.conf`. **AniCursor** automatiza el ciclo de vida, mapea los nombramientos "Windows -> Linux" y genera alias para asegurar un soporte transversal completo, devolviéndole vida a viejos artes en escritorios actuales.

---
Hecho con ♥ por **manuelprz**
