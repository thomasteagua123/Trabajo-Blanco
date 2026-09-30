#!/bin/bash

# ============================================================
# INSTALADOR DE ANDROID STUDIO
# Linux Mint 22 / Ubuntu 24.04
# ============================================================

# ------------------------------------------------------------
# CONFIGURACIÓN
# ------------------------------------------------------------

URL_ANDROID_STUDIO="https://edgedl.me.gvt1.com/android/studio/ide-zips/2026.1.4.8/android-studio-quail4-patch1-linux.tar.gz"

ARCHIVO_ANDROID_STUDIO="android-studio-quail4-patch1-linux.tar.gz"

DIRECTORIO_INSTALACION="/opt/android-studio"

NOMBRE_APLICACION="Android Studio"

# ------------------------------------------------------------
# COLORES
# ------------------------------------------------------------

VERDE="\033[0;32m"
AMARILLO="\033[1;33m"
ROJO="\033[0;31m"
AZUL="\033[0;34m"
SIN_COLOR="\033[0m"

# ------------------------------------------------------------
# FUNCIONES
# ------------------------------------------------------------

mostrar_ok() {
    echo -e "${VERDE}[OK]${SIN_COLOR} $1"
}

mostrar_aviso() {
    echo -e "${AMARILLO}[ADVERTENCIA]${SIN_COLOR} $1"
}

mostrar_error() {
    echo -e "${ROJO}[ERROR]${SIN_COLOR} $1"
}

mostrar_info() {
    echo -e "${AZUL}[INFO]${SIN_COLOR} $1"
}

# ------------------------------------------------------------
# VERIFICAR BASH
# ------------------------------------------------------------

if [ -z "${BASH_VERSION:-}" ]; then
    mostrar_error "Este script debe ejecutarse con Bash."
    echo
    echo "Ejecutalo con:"
    echo
    echo "    bash instalar-android-studio.sh"
    echo
    exit 1
fi

# ------------------------------------------------------------
# VERIFICAR SUDO
# ------------------------------------------------------------

echo
echo "=============================================="
echo "      INSTALADOR DE ANDROID STUDIO"
echo "=============================================="
echo

if ! command -v sudo >/dev/null 2>&1; then
    mostrar_error "sudo no está instalado."
    exit 1
fi

# ------------------------------------------------------------
# VERIFICAR JAVA
# ------------------------------------------------------------

echo
echo "----------------------------------------------"
echo "Verificando Java..."
echo "----------------------------------------------"

if command -v java >/dev/null 2>&1; then

    VERSION_JAVA=$(java -version 2>&1 | head -n 1)

    mostrar_ok "Java ya está instalado."
    echo "       $VERSION_JAVA"

else

    mostrar_aviso "Java no está instalado."
    echo "Instalando OpenJDK 21..."

    if sudo apt install -y openjdk-21-jdk; then
        mostrar_ok "OpenJDK 21 instalado correctamente."
    else
        mostrar_error "No se pudo instalar OpenJDK 21."
        exit 1
    fi

fi

# ------------------------------------------------------------
# VERIFICAR KOTLIN
# ------------------------------------------------------------

echo
echo "----------------------------------------------"
echo "Verificando Kotlin..."
echo "----------------------------------------------"

if command -v kotlin >/dev/null 2>&1; then

    VERSION_KOTLIN=$(kotlin -version 2>&1 | head -n 1)

    mostrar_ok "Kotlin ya está instalado."
    echo "       $VERSION_KOTLIN"

else

    mostrar_aviso "Kotlin no está instalado."
    echo "Intentando instalar Kotlin..."

    if sudo apt install -y kotlin; then

        mostrar_ok "Kotlin instalado correctamente."

    else

        mostrar_error "No se pudo instalar Kotlin mediante apt."
        echo
        echo "Kotlin no puede continuar automáticamente."
        echo "Revisá los repositorios de tu sistema."
        echo

        exit 1
    fi

fi

# ------------------------------------------------------------
# VERIFICAR ANDROID STUDIO
# ------------------------------------------------------------

echo
echo "----------------------------------------------"
echo "Verificando Android Studio..."
echo "----------------------------------------------"

if [ -x "$DIRECTORIO_INSTALACION/bin/studio" ]; then

    mostrar_ok "Android Studio ya está instalado."
    echo "       Ubicación: $DIRECTORIO_INSTALACION"

else

    mostrar_aviso "Android Studio no está instalado."

    # --------------------------------------------------------
    # VERIFICAR WGET
    # --------------------------------------------------------

    echo
    echo "Verificando wget..."

    if command -v wget >/dev/null 2>&1; then

        mostrar_ok "wget ya está instalado."

    else

        mostrar_aviso "wget no está instalado."
        echo "Instalando wget..."

        if sudo apt install -y wget; then
            mostrar_ok "wget instalado correctamente."
        else
            mostrar_error "No se pudo instalar wget."
            exit 1
        fi

    fi

    # --------------------------------------------------------
    # DESCARGAR ANDROID STUDIO
    # --------------------------------------------------------

    echo
    echo "----------------------------------------------"
    echo "Descargando Android Studio..."
    echo "----------------------------------------------"

    if [ -f "$ARCHIVO_ANDROID_STUDIO" ]; then

        mostrar_ok "El archivo de Android Studio ya existe."
        echo "       $ARCHIVO_ANDROID_STUDIO"

    else

        echo "Descargando:"
        echo "$URL_ANDROID_STUDIO"
        echo

        if wget --no-check-certificate \
            -O "$ARCHIVO_ANDROID_STUDIO" \
            "$URL_ANDROID_STUDIO"; then

            mostrar_ok "Android Studio descargado correctamente."

        else

            mostrar_error "No se pudo descargar Android Studio."
            exit 1

        fi

    fi

    # --------------------------------------------------------
    # VERIFICAR TAR
    # --------------------------------------------------------

    echo
    echo "Verificando tar..."

    if command -v tar >/dev/null 2>&1; then

        mostrar_ok "tar ya está instalado."

    else

        mostrar_aviso "tar no está instalado."
        echo "Instalando tar..."

        if sudo apt install -y tar; then
            mostrar_ok "tar instalado correctamente."
        else
            mostrar_error "No se pudo instalar tar."
            exit 1
        fi

    fi

    # --------------------------------------------------------
    # EXTRAER ANDROID STUDIO
    # --------------------------------------------------------

    echo
    echo "----------------------------------------------"
    echo "Extrayendo Android Studio..."
    echo "----------------------------------------------"

    DIRECTORIO_EXTRAIDO=$(tar -tzf "$ARCHIVO_ANDROID_STUDIO" | head -n 1 | cut -d "/" -f 1)

    if [ -z "$DIRECTORIO_EXTRAIDO" ]; then
        mostrar_error "No se pudo detectar el directorio extraído."
        exit 1
    fi

    echo "Directorio detectado: $DIRECTORIO_EXTRAIDO"

    rm -rf "$DIRECTORIO_EXTRAIDO"

    if tar -xzf "$ARCHIVO_ANDROID_STUDIO"; then

        mostrar_ok "Android Studio extraído correctamente."

    else

        mostrar_error "No se pudo extraer Android Studio."
        exit 1

    fi

    # --------------------------------------------------------
    # INSTALAR EN /OPT
    # --------------------------------------------------------

    echo
    echo "----------------------------------------------"
    echo "Instalando Android Studio..."
    echo "----------------------------------------------"

    if [ -d "$DIRECTORIO_INSTALACION" ]; then

        mostrar_info "Existe una instalación anterior."
        echo "Eliminándola..."

        sudo rm -rf "$DIRECTORIO_INSTALACION"

    fi

    if sudo mv "$DIRECTORIO_EXTRAIDO" "$DIRECTORIO_INSTALACION"; then

        mostrar_ok "Android Studio instalado en:"
        echo "       $DIRECTORIO_INSTALACION"

    else

        mostrar_error "No se pudo mover Android Studio a /opt."
        exit 1

    fi

fi

# ------------------------------------------------------------
# CREAR COMANDO ANDROID-STUDIO
# ------------------------------------------------------------

echo
echo "----------------------------------------------"
echo "Configurando comando android-studio..."
echo "----------------------------------------------"

if [ -x "$DIRECTORIO_INSTALACION/bin/studio" ]; then

    sudo ln -sf \
        "$DIRECTORIO_INSTALACION/bin/studio" \
        /usr/local/bin/android-studio

    mostrar_ok "Comando 'android-studio' configurado."

else

    mostrar_error "No se encontró el ejecutable de Android Studio:"
    echo "$DIRECTORIO_INSTALACION/bin/studio"
    exit 1

fi

# ------------------------------------------------------------
# CREAR ACCESO DIRECTO
# ------------------------------------------------------------

echo
echo "----------------------------------------------"
echo "Creando acceso directo..."
echo "----------------------------------------------"

DIRECTORIO_APLICACIONES="$HOME/.local/share/applications"
ARCHIVO_DESKTOP="$DIRECTORIO_APLICACIONES/android-studio.desktop"

mkdir -p "$DIRECTORIO_APLICACIONES"

ICONO="$DIRECTORIO_INSTALACION/bin/studio.png"

cat > "$ARCHIVO_DESKTOP" <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Android Studio
Comment=Desarrollo de aplicaciones Android
Exec=$DIRECTORIO_INSTALACION/bin/studio %f
Icon=$ICONO
Terminal=false
Categories=Development;IDE;
StartupWMClass=jetbrains-studio
EOF

chmod +x "$ARCHIVO_DESKTOP"

mostrar_ok "Acceso directo creado."

# ------------------------------------------------------------
# VERIFICACIÓN FINAL
# ------------------------------------------------------------

echo
echo "=============================================="
echo "        INSTALACIÓN FINALIZADA"
echo "=============================================="
echo

echo "Java:"
java -version 2>&1 | head -n 1

echo
echo "Kotlin:"
kotlin -version 2>&1 | head -n 1

echo
echo "Android Studio:"
"$DIRECTORIO_INSTALACION/bin/studio" --version 2>/dev/null || true

echo
echo "Podés iniciar Android Studio de estas formas:"
echo
echo "  1. Desde el menú de aplicaciones."
echo "  2. Desde la terminal:"
echo
echo "       android-studio"
echo

mostrar_ok "Proceso terminado."