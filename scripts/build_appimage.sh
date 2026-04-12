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

BUNDLE_DIR="build/linux/x64/release/bundle"

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
cp -r ../../../$BUNDLE_DIR/* $APPDIR/usr/bin/

# Crear archivo .desktop
cat > $APPDIR/usr/share/applications/anicursor.desktop << EOF
[Desktop Entry]
Name=AniCursor
Exec=anicursor
Icon=anicursor
Type=Application
Categories=Utility;
Terminal=false
EOF

# Copiar AppRun default
cat > $APPDIR/AppRun << EOF
#!/bin/sh
HERE="\$(dirname "\$(readlink -f "\${0}")")"
export LD_LIBRARY_PATH="\${HERE}/usr/bin/lib:\${LD_LIBRARY_PATH}"
exec "\${HERE}/usr/bin/anicursor" "\$@"
EOF
chmod +x $APPDIR/AppRun

# Copiar el SVG como icono principal
# Nota: AppImage necesita un PNG o SVG de fallback en la raiz 
cp ../../../assets/ani_xcursor_logo_v3.svg $APPDIR/anicursor.svg
cp ../../../assets/ani_xcursor_logo_v3.svg $APPDIR/usr/share/icons/hicolor/256x256/apps/anicursor.svg

echo "🚀 Empaquetando finalmente a .AppImage..."
./appimagetool-x86_64.AppImage $APPDIR AniCursor-x86_64.AppImage

echo "✅ Completado! AppImage disponible en build/appimage/AniCursor-x86_64.AppImage"
