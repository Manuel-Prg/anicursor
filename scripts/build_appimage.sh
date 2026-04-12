#!/bin/bash
# Scripts de compilación de AppImage para AniCursor

set -e

# Aseguremos que el script se lance desde la carpeta raiz
ROOT_DIR=$(pwd)
if [ ! -f "pubspec.yaml" ]; then
    echo "Por favor ejecuta este script desde la raiz del proyecto."
    exit 1
fi

echo "📦 Compilando aplicación Flutter Linux (Release)..."
flutter build linux

BUNDLE_DIR="$ROOT_DIR/build/linux/x64/release/bundle"

if [ ! -d "$BUNDLE_DIR" ]; then
    echo "❌ Fallo la compilación de Flutter."
    exit 1
fi

echo "📥 Descargando appimagetool..."
mkdir -p build/appimage
cd build/appimage
if [ ! -f "appimagetool-x86_64.AppImage" ]; then
    wget -qO appimagetool-x86_64.AppImage https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage
    chmod +x appimagetool-x86_64.AppImage
fi

echo "🏗️ Preparando AppDir..."
APPDIR="AniCursor.AppDir"
rm -rf $APPDIR
mkdir -p $APPDIR/usr/bin
mkdir -p $APPDIR/usr/share/applications
mkdir -p $APPDIR/usr/share/icons/hicolor/256x256/apps

# Copiar el build the flutter completo
cp -r "$BUNDLE_DIR/"* "$APPDIR/usr/bin/"

# Crear archivo .desktop verdadero
cat > "$APPDIR/com.manuelprz.anicursor.desktop" << EOF
[Desktop Entry]
Name=AniCursor
Exec=anicursor
Icon=anicursor
Type=Application
Categories=Utility;
Terminal=false
StartupWMClass=com.manuelprz.anicursor
EOF
cp "$APPDIR/com.manuelprz.anicursor.desktop" "$APPDIR/usr/share/applications/com.manuelprz.anicursor.desktop"

# Copiar AppRun default (Con Auto-Integración Wayland)
cat > $APPDIR/AppRun << EOF
#!/bin/sh
HERE="\$(dirname "\$(readlink -f "\${0}")")"
export LD_LIBRARY_PATH="\${HERE}/usr/bin/lib:\${LD_LIBRARY_PATH}"

# Auto integration para Wayland/GNOME
mkdir -p "\$HOME/.local/share/applications"
mkdir -p "\$HOME/.local/share/icons/hicolor/scalable/apps"
cp -f "\$HERE/com.manuelprz.anicursor.desktop" "\$HOME/.local/share/applications/" 2>/dev/null
cp -f "\$HERE/anicursor.svg" "\$HOME/.local/share/icons/hicolor/scalable/apps/" 2>/dev/null
update-desktop-database "\$HOME/.local/share/applications" 2>/dev/null || true

exec "\${HERE}/usr/bin/anicursor" "\\\$@"
EOF
chmod +x $APPDIR/AppRun

# Copiar el SVG como icono principal
# Nota: AppImage necesita un PNG o SVG de fallback en la raiz 
cp "$ROOT_DIR/assets/ani_xcursor_logo_v3.svg" "$APPDIR/anicursor.svg"
cp "$ROOT_DIR/assets/ani_xcursor_logo_v3.svg" "$APPDIR/usr/share/icons/hicolor/256x256/apps/anicursor.svg"

echo "🚀 Empaquetando finalmente a .AppImage..."
rm -f AniCursor-x86_64.AppImage
./appimagetool-x86_64.AppImage $APPDIR AniCursor-x86_64.AppImage

echo "✅ Completado! AppImage disponible en build/appimage/AniCursor-x86_64.AppImage"
