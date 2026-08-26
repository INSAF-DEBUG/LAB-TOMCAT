#!/bin/bash

set -e

# ======================================
# Détermination des chemins
# ======================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/../config/tomcat.conf"

# ======================================
# Vérification du fichier de configuration
# ======================================

if [ ! -f "$CONFIG_FILE" ]; then
    echo "Erreur : fichier de configuration introuvable : $CONFIG_FILE"
    exit 1
fi

source "$CONFIG_FILE"

# ======================================
# Vérification des privilèges
# ======================================

if [ "$EUID" -ne 0 ]; then
    echo "Erreur : ce script doit être exécuté en root."
    echo "Utilisez : sudo $0"
    exit 1
fi

# ======================================
# Informations
# ======================================

echo "======================================"
echo "      Installation de Apache Tomcat"
echo "======================================"

echo "Version Tomcat : $TOMCAT_VERSION"
echo "Utilisateur    : $TOMCAT_USER"
echo "Groupe         : $TOMCAT_GROUP"
echo "Répertoire     : $TOMCAT_DIR"
echo "Port HTTP      : $TOMCAT_PORT"
echo "Application    : $APP_NAME"
echo ""

# ======================================
# Vérification / installation de Java
# ======================================

echo "Vérification de Java..."

if ! command -v java >/dev/null 2>&1; then
    echo "Java n'est pas installé."
    echo "Installation de OpenJDK 8..."

    yum install -y java-1.8.0-openjdk-devel
else
    echo "Java est déjà installé."
fi

echo ""
echo "Version Java détectée :"
java -version

# ======================================
# Création de l'utilisateur Tomcat
# ======================================

echo ""
echo "Vérification de l'utilisateur Tomcat..."

if id "$TOMCAT_USER" >/dev/null 2>&1; then
    echo "L'utilisateur $TOMCAT_USER existe déjà."
else
    echo "Création de l'utilisateur $TOMCAT_USER..."

    useradd --system \
        --home-dir "$TOMCAT_DIR" \
        --shell /sbin/nologin \
        "$TOMCAT_USER"

    echo "Utilisateur $TOMCAT_USER créé."
fi

# ======================================
# Préparation du répertoire Tomcat
# ======================================

echo ""
echo "Préparation du répertoire Tomcat..."

mkdir -p "$TOMCAT_DIR"

echo "Répertoire préparé : $TOMCAT_DIR"

# ======================================
# Téléchargement de Tomcat
# ======================================

echo ""
echo "Téléchargement de Tomcat $TOMCAT_VERSION..."

TOMCAT_ARCHIVE="/tmp/apache-tomcat-${TOMCAT_VERSION}.tar.gz"

TOMCAT_URL="https://archive.apache.org/dist/tomcat/tomcat-9/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz"

curl -fL "$TOMCAT_URL" -o "$TOMCAT_ARCHIVE"

echo "Archive téléchargée : $TOMCAT_ARCHIVE"

# ======================================
# Extraction de Tomcat
# ======================================

echo ""
echo "Extraction de Tomcat..."

rm -rf "$TOMCAT_DIR"

tar -xzf "$TOMCAT_ARCHIVE" -C /opt

mv "/opt/apache-tomcat-${TOMCAT_VERSION}" "$TOMCAT_DIR"

echo "Tomcat installé dans : $TOMCAT_DIR"

# ======================================
# Configuration des permissions
# ======================================

echo ""
echo "Configuration des permissions..."

chown -R "$TOMCAT_USER:$TOMCAT_GROUP" "$TOMCAT_DIR"

chmod +x "$TOMCAT_DIR"/bin/*.sh

echo "Permissions configurées."

# ======================================
# Détermination de JAVA_HOME
# ======================================

echo ""
echo "Détermination de JAVA_HOME..."

JAVA_BIN="$(read
