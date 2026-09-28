#!/bin/bash

# ============================================================
# INSTALADOR COMPLETO - ANDROID STUDIO + ANDROID SDK
# Linux Mint 22 / Ubuntu 24.04 - x86_64
#
# Android Studio:
# Quail 4 | 2026.1.4 Patch 1
# ============================================================

set -u

# ============================================================
# CONFIGURACIÓN
# ============================================================

APP_NAME="Android Studio"

ANDROID_STUDIO_URL="https://edgedl.me.gvt1.com/android/studio/ide-zips/2026.1.4.8/android-studio-quail4-patch1-linux.tar.gz"

ANDROID_STUDIO_FILE="android-studio-quail4-patch1-linux.tar.gz"

INSTALL_DIR="/opt/android-studio"

SDK_DIR="$HOME/Android/Sdk"

CMDLINE_TOOLS_DIR="$SDK_DIR/cmdline-tools"
CMDLINE_TOOLS_LATEST="$CMDLINE_TOOLS_DIR/latest"

CMDLINE_TOOLS_URL="https://dl.google.com/android/repository/commandlinetools-linux-15859902_latest.zip"

CMDLINE_TOOLS_FILE="commandlinetools-linux-latest.zip"

TEMP_DIR="$HOME/.android-studio-installer-temp"

# Android 15
ANDROID_PLATFORM="platforms;android-35"

# Build Tools
BUILD_TOOLS="build-tools;36.0.0"

# Herramientas adicionales
SDK_PACKAGES=(
    "platform-tools"
    "emulator"
    "$ANDROID_PLATFORM"
    "$BUILD_TOOLS"
)

# ============================================================
# COLORES
# ============================================================

ROJO='\033[0;31m'
VERDE='\033[0;32m'
AMARILLO='\033[1;33m'
AZUL='\033[0;34m'
CIAN='\033[0;36m'
SIN_COLOR='\033[0m'

# ============================================================
# FUNCIONES
# ============================================================

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

mostrar_titulo() {
    echo
    echo "============================================================"
    echo "$1"
    echo "============================================================"
    echo
}

# ============================================================
# INICIO
# ============================================================

clear

echo
echo "============================================================"
echo "       INSTALADOR DE ANDROID STUDIO"
echo "============================================================"
echo
echo "Android Studio Quail 4 | 2026.1.4 Patch 1"
echo "Android SDK + ADB + Emulator"
echo
echo "============================================================"
echo

# ============================================================
# ETAPA 1 - VERIFICAR SISTEMA
# ============================================================

mostrar_titulo "ETAPA 1 - VERIFICACIÓN DEL SISTEMA"

if [ -f /etc/os-release ]; then
    . /etc/os-release

    echo "Sistema operativo:"
    echo "  $PRETTY_NAME"
    echo
else
    mostrar_aviso "No se pudo detectar /etc/os-release."
fi

ARQUITECTURA=$(uname -m)

echo "Arquitectura:"
echo "  $ARQUITECTURA"
echo

if [ "$ARQUITECTURA" != "x86_64" ]; then
    mostrar_error "Este instalador requiere una arquitectura x86_64."
    exit 1
fi

mostrar_ok "Arquitectura x86_64 compatible."

# ============================================================
# ETAPA 2 - ACTUALIZAR REPOSITORIOS
# ============================================================

mostrar_titulo "ETAPA 2 - ACTUALIZACIÓN DE REPOSITORIOS"

echo "Intentando actualizar los repositorios de paquetes..."
echo

if sudo apt update; then

    mostrar_ok "Repositorios actualizados correctamente."

else

    mostrar_aviso "No se pudieron actualizar completamente los repositorios."
    echo
    echo "Esto NO detendrá la instalación."
    echo "Se continuará utilizando la información disponible en apt."
    echo

fi

# ============================================================
# ETAPA 3 - VERIFICAR DEPENDENCIAS
# ============================================================

mostrar_titulo "ETAPA 3 - VERIFICACIÓN DE DEPENDENCIAS"

DEPENDENCIAS=(
    "wget"
    "curl"
    "tar"
    "unzip"
    "ca-certificates"
)

FALTANTES=()

for dependencia in "${DEPENDENCIAS[@]}"; do

    if command -v "$dependencia" >/dev/null 2>&1; then

        mostrar_ok "$dependencia ya está instalado."

    else

        mostrar_aviso "$dependencia no está instalado."
        FALTANTES+=("$dependencia")

    fi

done

# ============================================================
# INSTALAR DEPENDENCIAS FALTANTES
# ============================================================

if [ ${#FALTANTES[@]} -gt 0 ]; then

    echo
    echo "Dependencias faltantes:"
    printf '  - %s\n' "${FALTANTES[@]}"
    echo

    echo "Intentando instalarlas..."

    if sudo apt install -y "${FALTANTES[@]}"; then

        mostrar_ok "Dependencias instaladas correctamente."

    else

        mostrar_error "No se pudieron instalar todas las dependencias."

        echo
        echo "Dependencias faltantes:"
        printf '  - %s\n' "${FALTANTES[@]}"

        echo
        echo "La instalación no puede continuar porque estas herramientas"
        echo "son necesarias para descargar y extraer Android Studio."

        exit 1
    fi

else

    mostrar_ok "Todas las dependencias necesarias están instaladas."

fi

# ============================================================
# ETAPA 4 - VERIFICAR JAVA
# ============================================================

mostrar_titulo "ETAPA 4 - VERIFICACIÓN DE JAVA"

if command -v java >/dev/null 2>&1; then

    JAVA_VERSION=$(java -version 2>&1 | head -n 1)

    echo "Java detectado:"
    echo "  $JAVA_VERSION"
    echo

    JAVA_MAJOR=$(java -version 2>&1 | sed -n 's/.*version "\([0-9]*\).*/\1/p')

    if [ -n "$JAVA_MAJOR" ]; then

        if [ "$JAVA_MAJOR" -ge 17 ]; then

            mostrar_ok "Java $JAVA_MAJOR es compatible."

        else

            mostrar_aviso "Se detectó Java $JAVA_MAJOR."
            echo "Android Studio requiere una versión moderna de Java."
            echo "Se recomienda Java 17 o superior."

        fi

    else

        mostrar_aviso "No se pudo determinar la versión de Java."

    fi

else

    mostrar_aviso "Java no está instalado."

    echo
    echo "Intentando instalar OpenJDK 21..."
    echo

    if sudo apt install -y openjdk-21-jdk; then

        mostrar_ok "OpenJDK 21 instalado."

    else

        mostrar_error "No se pudo instalar Java."

        echo
        echo "Android Studio incluye su propio JBR,"
        echo "pero se recomienda tener Java instalado para"
        echo "herramientas externas y Gradle."

        exit 1
    fi

fi

# ============================================================
# ETAPA 5 - VERIFICAR ESPACIO
# ============================================================

mostrar_titulo "ETAPA 5 - VERIFICACIÓN DE ESPACIO"

ESPACIO_DISPONIBLE=$(df -Pk "$HOME" | awk 'NR==2 {print $4}')

ESPACIO_GB=$((ESPACIO_DISPONIBLE / 1024 / 1024))

echo "Espacio disponible:"
echo "  ${ESPACIO_GB} GB"
echo

if [ "$ESPACIO_GB" -lt 15 ]; then

    mostrar_aviso "Hay menos de 15 GB disponibles."

    echo "Android Studio + SDK + herramientas pueden ocupar"
    echo "varios GB."

    echo
    read -p "¿Querés continuar igualmente? [s/N]: " RESPUESTA

    if [[ ! "$RESPUESTA" =~ ^[sS]$ ]]; then
        echo
        echo "Instalación cancelada."
        exit 1
    fi

else

    mostrar_ok "Hay suficiente espacio disponible."

fi

# ============================================================
# ETAPA 6 - PREPARAR DIRECTORIO TEMPORAL
# ============================================================

mostrar_titulo "ETAPA 6 - PREPARACIÓN"

mkdir -p "$TEMP_DIR"

mostrar_ok "Directorio temporal preparado."

# ============================================================
# ETAPA 7 - DESCARGAR ANDROID STUDIO
# ============================================================

mostrar_titulo "ETAPA 7 - ANDROID STUDIO"

if [ -d "$INSTALL_DIR" ]; then

    mostrar_ok "Android Studio ya está instalado en:"
    echo "  $INSTALL_DIR"

else

    echo "Android Studio no está instalado."
    echo

    if [ -f "$ANDROID_STUDIO_FILE" ]; then

        mostrar_ok "El archivo de Android Studio ya existe."
        echo "Se reutilizará la descarga."

    else

        echo "Descargando Android Studio..."
        echo
        echo "Archivo:"
        echo "  $ANDROID_STUDIO_FILE"
        echo

        if wget \
            --progress=bar:force \
            -O "$ANDROID_STUDIO_FILE" \
            "$ANDROID_STUDIO_URL"; then

            echo
            mostrar_ok "Android Studio descargado correctamente."

        else

            echo
            mostrar_error "No se pudo descargar Android Studio."

            echo
            echo "URL:"
            echo "$ANDROID_STUDIO_URL"

            exit 1
        fi

    fi

    # --------------------------------------------------------
    # OBTENER DIRECTORIO INTERNO
    # --------------------------------------------------------

    EXTRACTED_DIR=$(tar -tzf "$ANDROID_STUDIO_FILE" | head -n 1 | cut -d/ -f1)

    if [ -z "$EXTRACTED_DIR" ]; then

        mostrar_error "No se pudo determinar el directorio de Android Studio."

        exit 1

    fi

    echo
    echo "Directorio detectado:"
    echo "  $EXTRACTED_DIR"

    # --------------------------------------------------------
    # EXTRAER
    # --------------------------------------------------------

    echo
    echo "Extrayendo Android Studio..."

    if tar -xzf "$ANDROID_STUDIO_FILE"; then

        mostrar_ok "Android Studio extraído correctamente."

    else

        mostrar_error "No se pudo extraer Android Studio."
        exit 1

    fi

    # --------------------------------------------------------
    # ELIMINAR INSTALACIÓN ANTERIOR
    # --------------------------------------------------------

    if [ -d "$INSTALL_DIR" ]; then

        echo
        mostrar_info "Eliminando instalación anterior..."

        sudo rm -rf "$INSTALL_DIR"

    fi

    # --------------------------------------------------------
    # MOVER A /opt
    # --------------------------------------------------------

    echo
    echo "Instalando Android Studio en:"
    echo "  $INSTALL_DIR"
    echo

    if sudo mv "$EXTRACTED_DIR" "$INSTALL_DIR"; then

        mostrar_ok "Android Studio instalado correctamente."

    else

        mostrar_error "No se pudo mover Android Studio a $INSTALL_DIR."
        exit 1

    fi

fi

# ============================================================
# ETAPA 8 - CREAR COMANDO ANDROID-STUDIO
# ============================================================

mostrar_titulo "ETAPA 8 - COMANDO ANDROID-STUDIO"

if [ -x "$INSTALL_DIR/bin/studio" ]; then

    sudo ln -sf "$INSTALL_DIR/bin/studio" /usr/local/bin/android-studio

    mostrar_ok "Comando 'android-studio' configurado."

elif [ -x "$INSTALL_DIR/bin/studio.sh" ]; then

    sudo ln -sf "$INSTALL_DIR/bin/studio.sh" /usr/local/bin/android-studio

    mostrar_ok "Comando 'android-studio' configurado."

else

    mostrar_error "No se encontró el ejecutable de Android Studio."

    exit 1

fi

# ============================================================
# ETAPA 9 - CREAR ACCESO DIRECTO
# ============================================================

mostrar_titulo "ETAPA 9 - ACCESO DIRECTO"

APPLICATIONS_DIR="$HOME/.local/share/applications"

mkdir -p "$APPLICATIONS_DIR"

DESKTOP_FILE="$APPLICATIONS_DIR/android-studio.desktop"

ICON_PATH="$INSTALL_DIR/bin/studio.png"

cat > "$DESKTOP_FILE" <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Android Studio
Comment=Desarrollo de aplicaciones Android
Exec=$INSTALL_DIR/bin/studio %f
Icon=$ICON_PATH
Terminal=false
Categories=Development;IDE;
StartupWMClass=jetbrains-studio
EOF

chmod +x "$DESKTOP_FILE"

mostrar_ok "Acceso directo creado."

# ============================================================
# ETAPA 10 - ANDROID SDK
# ============================================================

mostrar_titulo "ETAPA 10 - CONFIGURACIÓN DEL ANDROID SDK"

echo "Directorio del SDK:"
echo "  $SDK_DIR"
echo

mkdir -p "$SDK_DIR"
mkdir -p "$CMDLINE_TOOLS_DIR"

mostrar_ok "Directorio del SDK preparado."

# ============================================================
# ETAPA 11 - COMMAND-LINE TOOLS
# ============================================================

mostrar_titulo "ETAPA 11 - ANDROID COMMAND-LINE TOOLS"

SDKMANAGER="$CMDLINE_TOOLS_LATEST/bin/sdkmanager"

if [ -x "$SDKMANAGER" ]; then

    mostrar_ok "Command-Line Tools ya están instaladas."

else

    echo "Command-Line Tools no encontradas."
    echo "Descargando desde Google..."
    echo

    CMDLINE_ZIP="$TEMP_DIR/$CMDLINE_TOOLS_FILE"

    if [ -f "$CMDLINE_ZIP" ]; then

        mostrar_ok "La descarga ya existe. Se reutilizará."

    else

        if wget \
            --progress=bar:force \
            -O "$CMDLINE_ZIP" \
            "$CMDLINE_TOOLS_URL"; then

            echo
            mostrar_ok "Command-Line Tools descargadas."

        else

            mostrar_error "No se pudieron descargar las Command-Line Tools."

            echo
            echo "URL:"
            echo "$CMDLINE_TOOLS_URL"

            exit 1
        fi

    fi

    # --------------------------------------------------------
    # DIRECTORIO TEMPORAL DE EXTRACCIÓN
    # --------------------------------------------------------

    CMDLINE_EXTRACT="$TEMP_DIR/cmdline-tools"

    rm -rf "$CMDLINE_EXTRACT"

    mkdir -p "$CMDLINE_EXTRACT"

    echo
    echo "Extrayendo Command-Line Tools..."

    if unzip -q "$CMDLINE_ZIP" -d "$CMDLINE_EXTRACT"; then

        mostrar_ok "Command-Line Tools extraídas."

    else

        mostrar_error "No se pudieron extraer las Command-Line Tools."
        exit 1

    fi

    # --------------------------------------------------------
    # LIMPIAR LATEST ANTERIOR
    # --------------------------------------------------------

    rm -rf "$CMDLINE_TOOLS_LATEST"

    mkdir -p "$CMDLINE_TOOLS_LATEST"

    # --------------------------------------------------------
    # MOVER CONTENIDO
    # --------------------------------------------------------

    if [ -d "$CMDLINE_EXTRACT/cmdline-tools" ]; then

        cp -a "$CMDLINE_EXTRACT/cmdline-tools/." \
            "$CMDLINE_TOOLS_LATEST/"

    else

        mostrar_error "La descarga no tiene la estructura esperada."
        exit 1

    fi

    # --------------------------------------------------------
    # VERIFICAR SDKMANAGER
    # --------------------------------------------------------

    SDKMANAGER="$CMDLINE_TOOLS_LATEST/bin/sdkmanager"

    if [ -x "$SDKMANAGER" ]; then

        mostrar_ok "sdkmanager instalado correctamente."

    else

        mostrar_error "sdkmanager no fue encontrado."
        exit 1

    fi

fi

# ============================================================
# ETAPA 12 - VARIABLES DE ENTORNO
# ============================================================

mostrar_titulo "ETAPA 12 - VARIABLES DE ENTORNO"

BASHRC="$HOME/.bashrc"
PROFILE="$HOME/.profile"

# ------------------------------------------------------------
# BASHRC
# ------------------------------------------------------------

if ! grep -q 'ANDROID_HOME="$HOME/Android/Sdk"' "$BASHRC" 2>/dev/null; then

    cat >> "$BASHRC" <<'EOF'

# ============================================================
# Android SDK
# ============================================================

export ANDROID_HOME="$HOME/Android/Sdk"
export ANDROID_SDK_ROOT="$HOME/Android/Sdk"

export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$PATH"

EOF

    mostrar_ok "Android SDK agregado a ~/.bashrc."

else

    mostrar_ok "Android SDK ya estaba configurado en ~/.bashrc."

fi

# ------------------------------------------------------------
# PROFILE
# ------------------------------------------------------------

if ! grep -q 'ANDROID_HOME="$HOME/Android/Sdk"' "$PROFILE" 2>/dev/null; then

    cat >> "$PROFILE" <<'EOF'

# ============================================================
# Android SDK
# ============================================================

export ANDROID_HOME="$HOME/Android/Sdk"
export ANDROID_SDK_ROOT="$HOME/Android/Sdk"

export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$PATH"

EOF

    mostrar_ok "Android SDK agregado a ~/.profile."

else

    mostrar_ok "Android SDK ya estaba configurado en ~/.profile."

fi

# ------------------------------------------------------------
# CARGAR VARIABLES EN ESTA SESIÓN
# ------------------------------------------------------------

export ANDROID_HOME="$SDK_DIR"
export ANDROID_SDK_ROOT="$SDK_DIR"

export PATH="$CMDLINE_TOOLS_LATEST/bin:$SDK_DIR/platform-tools:$SDK_DIR/emulator:$PATH"

mostrar_ok "Variables de entorno cargadas."

# ============================================================
# ETAPA 13 - LICENCIAS
# ============================================================

mostrar_titulo "ETAPA 13 - LICENCIAS DEL ANDROID SDK"

echo "Aceptando las licencias del Android SDK..."
echo
echo "Esto puede tardar unos segundos."
echo

if yes | "$SDKMANAGER" --sdk_root="$SDK_DIR" --licenses >/dev/null 2>&1; then

    mostrar_ok "Licencias aceptadas."

else

    mostrar_aviso "No se pudieron aceptar automáticamente todas las licencias."
    echo
    echo "Podrás aceptarlas posteriormente desde Android Studio"
    echo "o ejecutando:"
    echo
    echo "  sdkmanager --licenses"

fi

# ============================================================
# ETAPA 14 - INSTALAR COMPONENTES DEL SDK
# ============================================================

mostrar_titulo "ETAPA 14 - COMPONENTES DEL ANDROID SDK"

echo "Se instalarán los siguientes componentes:"
echo
echo "  - Android SDK Platform-Tools"
echo "  - Android Emulator"
echo "  - Android SDK Platform 35"
echo "  - Android SDK Build-Tools 36.0.0"
echo

for paquete in "${SDK_PACKAGES[@]}"; do

    echo
    echo "------------------------------------------------------------"
    echo "Instalando: $paquete"
    echo "------------------------------------------------------------"
    echo

    if "$SDKMANAGER" \
        --sdk_root="$SDK_DIR" \
        "$paquete"; then

        mostrar_ok "$paquete instalado correctamente."

    else

        mostrar_error "No se pudo instalar: $paquete"

        echo
        echo "La instalación del SDK no pudo completarse."
        echo
        echo "Podés intentar posteriormente con:"
        echo
        echo "  sdkmanager \"$paquete\""
        echo

        exit 1

    fi

done

# ============================================================
# ETAPA 15 - PERMISOS DE ADB
# ============================================================

mostrar_titulo "ETAPA 15 - CONFIGURACIÓN DE ADB"

echo "Verificando reglas USB para dispositivos Android..."
echo

if dpkg -s android-sdk-platform-tools-common >/dev/null 2>&1; then

    mostrar_ok "Reglas USB de Android ya están instaladas."

else

    echo "El paquete android-sdk-platform-tools-common no está instalado."
    echo
    echo "Intentando instalarlo..."

    if sudo apt install -y android-sdk-platform-tools-common; then

        mostrar_ok "Reglas USB instaladas."

    else

        mostrar_aviso "No se pudieron instalar las reglas USB."
        echo
        echo "ADB seguirá instalado, pero algunos dispositivos físicos"
        echo "podrían requerir configuración adicional de permisos USB."

    fi

fi

# ============================================================
# ETAPA 16 - VERIFICACIÓN FINAL
# ============================================================

mostrar_titulo "ETAPA 16 - VERIFICACIÓN FINAL"

ERRORES=0

# ------------------------------------------------------------
# ANDROID STUDIO
# ------------------------------------------------------------

echo "Android Studio:"
echo

if [ -x "$INSTALL_DIR/bin/studio" ]; then

    mostrar_ok "Android Studio está instalado."

else

    mostrar_error "No se encontró Android Studio."
    ERRORES=$((ERRORES + 1))

fi

# ------------------------------------------------------------
# SDK
# ------------------------------------------------------------

echo
echo "Android SDK:"

if [ -d "$SDK_DIR" ]; then

    mostrar_ok "Android SDK encontrado:"
    echo "  $SDK_DIR"

else

    mostrar_error "Android SDK no encontrado."
    ERRORES=$((ERRORES + 1))

fi

# ------------------------------------------------------------
# SDKMANAGER
# ------------------------------------------------------------

echo
echo "sdkmanager:"

if [ -x "$SDKMANAGER" ]; then

    SDKMANAGER_VERSION=$("$SDKMANAGER" --version 2>/dev/null)

    mostrar_ok "sdkmanager funcionando."

    if [ -n "$SDKMANAGER_VERSION" ]; then
        echo "  Versión: $SDKMANAGER_VERSION"
    fi

else

    mostrar_error "sdkmanager no está disponible."
    ERRORES=$((ERRORES + 1))

fi

# ------------------------------------------------------------
# ADB
# ------------------------------------------------------------

echo
echo "ADB:"

ADB_PATH="$SDK_DIR/platform-tools/adb"

if [ -x "$ADB_PATH" ]; then

    mostrar_ok "ADB está instalado."

    echo
    "$ADB_PATH" version | head -n 1

else

    mostrar_error "ADB no fue encontrado."
    ERRORES=$((ERRORES + 1))

fi

# ------------------------------------------------------------
# EMULATOR
# ------------------------------------------------------------

echo
echo "Emulador Android:"

EMULATOR_PATH="$SDK_DIR/emulator/emulator"

if [ -x "$EMULATOR_PATH" ]; then

    mostrar_ok "Android Emulator está instalado."

else

    mostrar_error "Android Emulator no fue encontrado."
    ERRORES=$((ERRORES + 1))

fi

# ------------------------------------------------------------
# PLATFORM 35
# ------------------------------------------------------------

echo
echo "Android Platform 35:"

if [ -d "$SDK_DIR/platforms/android-35" ]; then

    mostrar_ok "Android SDK Platform 35 está instalado."

else

    mostrar_error "Android SDK Platform 35 no fue encontrado."
    ERRORES=$((ERRORES + 1))

fi

# ------------------------------------------------------------
# BUILD TOOLS
# ------------------------------------------------------------

echo
echo "Build Tools 36.0.0:"

if [ -d "$SDK_DIR/build-tools/36.0.0" ]; then

    mostrar_ok "Build Tools 36.0.0 están instaladas."

else

    mostrar_error "Build Tools 36.0.0 no fueron encontradas."
    ERRORES=$((ERRORES + 1))

fi

# ------------------------------------------------------------
# COMANDO GLOBAL
# ------------------------------------------------------------

echo
echo "Comando android-studio:"

if command -v android-studio >/dev/null 2>&1; then

    mostrar_ok "El comando 'android-studio' está disponible."

else

    mostrar_error "El comando 'android-studio' no está disponible."
    ERRORES=$((ERRORES + 1))

fi

# ============================================================
# LIMPIEZA
# ============================================================

mostrar_titulo "LIMPIEZA"

echo "Eliminando archivos temporales..."

rm -rf "$TEMP_DIR"

mostrar_ok "Archivos temporales eliminados."

# ============================================================
# RESULTADO FINAL
# ============================================================

mostrar_titulo "RESULTADO FINAL"

if [ "$ERRORES" -eq 0 ]; then

    echo -e "${VERDE}"
    echo "============================================================"
    echo "       INSTALACIÓN COMPLETADA CORRECTAMENTE"
    echo "============================================================"
    echo -e "${SIN_COLOR}"

    echo
    echo "Android Studio:"
    echo "  $INSTALL_DIR"

    echo
    echo "Android SDK:"
    echo "  $SDK_DIR"

    echo
    echo "Comando:"
    echo "  android-studio"

    echo
    echo "ADB:"
    echo "  adb"

    echo
    echo "SDK Manager:"
    echo "  sdkmanager"

    echo
    echo "============================================================"
    echo

    echo "Para aplicar las variables de entorno en una terminal nueva:"
    echo
    echo "  source ~/.bashrc"
    echo

    echo "O simplemente cerrá y abrí la terminal nuevamente."
    echo

else

    echo -e "${ROJO}"
    echo "============================================================"
    echo "       INSTALACIÓN TERMINADA CON ADVERTENCIAS"
    echo "============================================================"
    echo -e "${SIN_COLOR}"

    echo
    echo "Se detectaron $ERRORES problema(s)."
    echo
    echo "Revisá los mensajes anteriores."
    echo

    exit 1

fi

# ============================================================
# FIN
# ============================================================